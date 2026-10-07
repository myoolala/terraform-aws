import liteUtils from 'lite-utils';
const Logger = liteUtils.Logger;
const logger = new Logger({ level: 'INFO' });
import fs from 'fs';
import path from 'path';
import { loadConfig } from './config.mjs';
// Hook integration
let hooks = {}; // will be populated in handler

async function callHook(name, ...args) {
  // DEBUG: invoking hook or fallback
  logger.debug('callHook called', { name, args: args.slice(0,2) });
  if (hooks && typeof hooks[name] === 'function') {
    try {
      const result = await hooks[name](...args);
      logger.debug('hook result', { name, result });
      return result;
    } catch (e) {
      logger.warn(`Hook ${name} error`, e);
    }
  } else if (name === 'generatePassword') {
    logger.debug('calling default generatePassword');
    return generatePassword(...args);
  }
  logger.debug('no suitable hook or fallback for', { name });
  return undefined;
}

// configPromise delayed until handler call to ensure env variables are loaded at runtime

import { IAMClient, CreateAccessKeyCommand, ListAccessKeysCommand, UpdateAccessKeyCommand, DeleteAccessKeyCommand } from '@aws-sdk/client-iam';
import { RDSClient, ModifyDBInstanceCommand, ModifyDBClusterCommand } from '@aws-sdk/client-rds';
import { SecretsManagerClient, GetSecretValueCommand, PutSecretValueCommand } from '@aws-sdk/client-secrets-manager';
import { SSMClient, PutParameterCommand } from '@aws-sdk/client-ssm';
const iamClient = new IAMClient({});



const rdsClient = new RDSClient({});
const secretsClient = new SecretsManagerClient({});
const ssmClient = new SSMClient({});

// Password generation utility
/**
 * Generates a random password string.
 *
 * @param {number} length - Length of the password. Defaults to 33.
 * @param {string} allowedChars - Characters that may appear in the password.
 * @returns {string} Randomly generated password.
 */
function generatePassword(length = 33, allowedChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()-_=+') {
  // DEBUG: validate length
  if (typeof length !== 'number' || length <= 0) {
    throw new Error('Length must be a positive integer');
  }
  const chars = allowedChars;
  const result = [];
  for (let i = 0; i < length; i++) {
    const idx = Math.floor(Math.random() * chars.length);
    result.push(chars[idx]);
  }
  return result.join('');
}

/**
 * Stores a password in AWS Secrets Manager.
 *
 * @param {string} secretArn - ARN of the secret.
 * @param {any} creds - Credential value to store (typically the new password).
 */
async function storeSecretsManager(secretArn, creds) {
  if (!secretArn) {
    logger.warn('No secret ARN provided for Secrets Manager store');
    return;
  }
  const payload = JSON.stringify({ password: creds });
  await secretsClient.send(
    new PutSecretValueCommand({ SecretId: secretArn, SecretString: payload })
  );
  logger.info(`Stored credentials in Secrets Manager: ${secretArn}`);
}

/**
 * Stores a password as a SecureString in SSM Parameter Store.
 *
 * @param {string} paramName - SSM parameter name.
 * @param {any} creds - Credential value to store (typically the new password).
 */
async function storeSSMParam(paramName, creds) {
  if (!paramName) {
    logger.warn('No SSM parameter name provided for storing credentials');
    return;
  }
  await ssmClient.send(
    new PutParameterCommand({ Name: paramName, Value: creds, Type: 'SecureString', Overwrite: true })
  );
  logger.info(`Stored credentials in SSM Parameter: ${paramName}`);
}

/**
 * Reverts an RDS master password change.
 *
 * @param {object} cfg - Configuration object.
 * @param {string} identifier - DB instance or cluster identifier.
 * @param {string} oldPassword - Previous master password.
 */
async function rollbackRdsPassword(cfg, identifier, oldPassword) {
  if (!oldPassword) {
    logger.warn('No old password provided, cannot rollback RDS password');
    return;
  }
  const isInstance = cfg.secretLocation.includes(':db:');
  const isCluster = cfg.secretLocation.includes(':cluster:');
  if (isInstance) {
    await rdsClient.send(
      new ModifyDBInstanceCommand({ DBInstanceIdentifier: identifier, MasterUserPassword: oldPassword })
    );
    await callHook('onRevert', { identifier, oldPassword });
  } else if (isCluster) {
    await rdsClient.send(
      new ModifyDBClusterCommand({ DBClusterIdentifier: identifier, MasterUserPassword: oldPassword })
    );
    await callHook('onRevert', { identifier, oldPassword });
  }
}

/**
 * Rotates an RDS master password.
 *
 * @param {object} cfg - Configuration object.
 * @param {string} newPassword - New password to set.
 * @returns {object} An object containing the identifier and previous password.
 */
async function rotateRdsPassword(cfg, newPassword) {
  if (!cfg.secretLocation) {
    logger.warn('No secretLocation provided, cannot rotate RDS password');
    throw new Error('Missing secretLocation');
  }
  const isInstance = cfg.secretLocation.includes(':db:');
  const isCluster = cfg.secretLocation.includes(':cluster:');
  const identifier = cfg.secretLocation.split(':').pop();
  let oldPassword = null;
  // Fetch current password from Secrets Manager if stored
  if (cfg.secretStore === 'secretsmanager' && cfg.secretStoreLocation) {
    try {
      const { SecretString } = await secretsClient.send(
        new GetSecretValueCommand({ SecretId: cfg.secretStoreLocation })
      );
      const parsed = JSON.parse(SecretString || '{}');
      oldPassword = parsed.password;
      // hook call removed: onGetSecret is now handled in handler
    } catch (e) {
      logger.warn('Could not retrieve current password from Secrets Manager', e);
    }
  }
  // perform rotation
  if (hooks.updatePassword && typeof hooks.updatePassword === 'function') {
    await hooks.updatePassword(cfg, identifier, newPassword);
    await callHook('onPasswordUpdated', { identifier, oldPassword, newPassword });
    return { identifier, oldPassword };
  }
  if (isInstance) {
    await rdsClient.send(
      new ModifyDBInstanceCommand({ DBInstanceIdentifier: identifier, MasterUserPassword: newPassword })
    );
    await callHook('onPasswordUpdated', { identifier, oldPassword, newPassword });
  } else if (isCluster) {
    await rdsClient.send(
      new ModifyDBClusterCommand({ DBClusterIdentifier: identifier, MasterUserPassword: newPassword })
    );
    await callHook('onPasswordUpdated', { identifier, oldPassword, newPassword });
  } else {
    logger.warn('secretLocation ARN not recognized as RDS instance or cluster');
    throw new Error('Invalid secretLocation');
  }
  logger.info(`Updated RDS ${identifier} master password`);
  return { identifier, oldPassword };
}

/**
 * Deletes an IAM access key, used during rollback.
 *
 * @param {object} cfg - Configuration object.
 * @param {string} userName - IAM username.
 * @param {string} newKeyId - Access key ID to delete.
 */
async function rollbackIamAccessKey(cfg, userName, newKeyId) {
  try {
    await iamClient.send(new DeleteAccessKeyCommand({ UserName: userName, AccessKeyId: newKeyId }));
    await callHook('onRevert', { userName, newKeyId });
    logger.info(`Deleted rolled back IAM access key ${newKeyId} for user ${userName}`);
  } catch (e) {
    logger.warn(`Failed to delete IAM access key ${newKeyId} during rollback`, e);
  }
}

/**
 * Rotates IAM user access keys.
 *
 * @param {object} cfg - Configuration object.
 * @returns {object} Newly created key and a list of former key IDs that were disabled.
 */
async function rotateIamAccessKey(cfg) {
  if (!cfg.secretLocation) {
    logger.warn('No secretLocation provided, cannot rotate IAM user key');
    throw new Error('Missing secretLocation');
  }
  const userName = cfg.secretLocation; // assume IAM username
  const createResp = await iamClient.send(new CreateAccessKeyCommand({ UserName: userName }));
  const newKey = createResp.AccessKey;
  const listResp = await iamClient.send(new ListAccessKeysCommand({ UserName: userName }));
  const oldKeys = [];
  for (const keyMeta of listResp.AccessKeyMetadata || []) {
    if (keyMeta.AccessKeyId !== newKey.AccessKeyId) {
      await iamClient.send(new UpdateAccessKeyCommand({ UserName: userName, AccessKeyId: keyMeta.AccessKeyId, Status: 'DISABLED' }));
      oldKeys.push(keyMeta.AccessKeyId);
    }
  }
  logger.info(`Rotated IAM access key for user ${userName}`);
  return { newKey, oldKeys };
}


/**
 * Lambda handler for rotating credentials.
 *
 * @param {object} event Optional event payload; may contain `secret_type`.
 * @returns {void}
 */
export const handler = async (event) => {
  logger.debug('Handler invoked with event and config placeholders', { event });
  const cfg = await loadConfig();
  logger.debug('Configuration loaded in handler:', cfg);

  // Load hooks based on config after configuration is available
  const hookFilePath = cfg.hookFilePath || '/opt/hooks.mjs';
  logger.debug('Hook file path resolved:', hookFilePath);
  try {
  logger.debug('Checking if hook file exists at:', hookFilePath);
    if (fs.existsSync(hookFilePath)) {
      logger.debug('Hook file found, loading...');
      // Use dynamic import for ESM compatibility
      hooks = (await import('file://' + hookFilePath)).default || {};
      logger.debug('Hooks loaded:', typeof hooks, hooks);
    }
  } catch (hookErr) {
    logger.warn('Failed to load hooks', hookErr);
  }
  await callHook('onStart');
  const secretType = cfg.passwordType || event?.secret_type || 'unknown';
  logger.info('Secret type to rotate:', secretType);
  const newPassword = await callHook('generatePassword');
  await callHook('onGeneratePassword', newPassword);
  let rotationInfo = null;

// Rotate credential using hook or fallback
    if (secretType === 'RDS' || secretType === 'IAM_USER_ACCESS_TOKEN') {
      rotationInfo = await callHook('rotateCredential', cfg, newPassword, secretType);
      if (!rotationInfo) {
        // Fallback to original
        if (secretType === 'RDS') {
          rotationInfo = await rotateRdsPassword(cfg, newPassword);
        } else {
          rotationInfo = await rotateIamAccessKey(cfg);
        }
      }
    }

// Storage and cleanup using hook or fallback
    if (rotationInfo) {
      try {
        if (hooks.saveCredential && typeof hooks.saveCredential === 'function') {
          await hooks.saveCredential(cfg, secretType, cfg.secretStore, cfg.secretStoreLocation, newPassword, rotationInfo);
        } else if (cfg.secretStore === 'secretsmanager') {
          if (secretType === 'RDS') {
            await storeSecretsManager(cfg.secretStoreLocation, newPassword);
          } else if (secretType === 'IAM_USER_ACCESS_TOKEN') {
            await storeSecretsManager(cfg.secretStoreLocation, JSON.stringify({ accessKeyId: rotationInfo.newKey.AccessKeyId, secretAccessKey: rotationInfo.newKey.SecretAccessKey }));
          }
        } else if (cfg.secretStore === 'ssm') {
          if (secretType === 'RDS') {
            await storeSSMParam(cfg.secretStoreLocation, newPassword);
          } else if (secretType === 'IAM_USER_ACCESS_TOKEN') {
            await storeSSMParam(cfg.secretStoreLocation, JSON.stringify({ accessKeyId: rotationInfo.newKey.AccessKeyId, secretAccessKey: rotationInfo.newKey.SecretAccessKey }));
          }
        }
        // Delete old IAM keys after successful store for IAM
        if (secretType === 'IAM_USER_ACCESS_TOKEN' && Array.isArray(rotationInfo.oldKeys)) {
          for (const oldKeyId of rotationInfo.oldKeys) {
            if (hooks.deleteIamAccessKey && typeof hooks.deleteIamAccessKey === 'function') {
              await hooks.deleteIamAccessKey(cfg, cfg.secretLocation, oldKeyId);
            } else {
              await iamClient.send(new DeleteAccessKeyCommand({ UserName: cfg.secretLocation, AccessKeyId: oldKeyId }));
            }
          }
        }
      } catch (storeErr) {
        logger.error('Failed to store new credentials, attempting revert', storeErr);
        if (hooks.rollBackCredential && typeof hooks.rollBackCredential === 'function') {
          await hooks.rollBackCredential(cfg, secretType, cfg.secretStore, cfg.secretStoreLocation, rotationInfo, storeErr);
        } else {
          if (secretType === 'RDS' && rotationInfo.oldPassword) {
            await rollbackRdsPassword(cfg, rotationInfo.identifier, rotationInfo.oldPassword);
          } else if (secretType === 'IAM_USER_ACCESS_TOKEN') {
            await rollbackIamAccessKey(cfg, cfg.secretLocation, rotationInfo.newKey.AccessKeyId);
          }
        }
        throw storeErr;
      }
      
      await callHook('onComplete');
    }
};