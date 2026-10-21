// Custom hooks for rotating IAM user SMTP credentials

import { IAMClient, GetLoginProfileCommand, CreateLoginProfileCommand, DeleteLoginProfileCommand } from "@aws-sdk/client-iam";
import { SSMClient, PutParameterCommand } from "@aws-sdk/client-ssm";
import { SecretsManagerClient, PutSecretValueCommand } from "@aws-sdk/client-secrets-manager";
import { SNSClient, PublishCommand } from "@aws-sdk/client-sns";
import crypto from "crypto";

const iamClient = new IAMClient({});
const ssmClient = new SSMClient({});
const secretManagerClient = new SecretsManagerClient({});
const snsClient = new SNSClient({});

const IAM_USER = process.env.IAM_USER;
const SSM_PARAMETER = process.env.SSM_PARAMETER;
const SECRETS_MANAGER_SECRET = process.env.SECRETS_MANAGER_SECRET;
const SNS_TOPIC = process.env.SNS_TOPIC;

function generatePassword(length = 24) {
  // generate a secure random string; base64 may contain / + which are allowed
  return crypto.randomBytes(length).toString("base64").slice(0, length);
}

async function sendSmsTopic(message) {
  if (!SNS_TOPIC) return;
  try {
    await snsClient.send(new PublishCommand({
      TopicArn: SNS_TOPIC,
      Subject: `SMTP Credential Rotation Failed for ${IAM_USER}`,
      Message: message
    }));
  } catch (e) {
    // log failure, but don't throw to avoid breaking lambda chain
    console.error("Failed to publish SNS message:", e);
  }
}

export default {
  async getCurrentCredentials() {
    try {
      const res = await iamClient.send(new GetLoginProfileCommand({ UserName: IAM_USER }));
      // If password is reset required, treat as no credentials
      if (res.LoginProfile && !res.LoginProfile.PasswordResetRequired) {
        return { password: res.LoginProfile.PasswordResetRequired ? null : IAM_USER };
      }
      return null;
    } catch (e) {
      if (e.name === "NoSuchEntity") {
        console.error('Could not find the IAM User');
      }
      // Non-entity errors propagate
      throw e;
    }
  },

  async generateCredentials() {
    const password = generatePassword(20);
    return { password };
  },

  async updateCredentials(oldCreds, newCreds) {
    // Delete existing login profile if present to avoid CreateLoginProfile conflict
    if (oldCreds) {
      try {
        await iamClient.send(new DeleteLoginProfileCommand({ UserName: IAM_USER }));
      } catch (e) {
        // Ignore if already deleted
        if (e.name !== "NoSuchEntity") throw e;
      }
    }
    await iamClient.send(new CreateLoginProfileCommand({
      UserName: IAM_USER,
      Password: newCreds.password,
      PasswordResetRequired: true
    }));
    return newCreds;
  },

  async storeCredentials(updatedCreds) {
    const payload = JSON.stringify(updatedCreds);
    if (SSM_PARAMETER) {
      await ssmClient.send(new PutParameterCommand({
        Name: SSM_PARAMETER,
        Value: payload,
        Type: "SecureString",
        Overwrite: true
      }));
    } else if (SECRETS_MANAGER_SECRET) {
      await secretManagerClient.send(new PutSecretValueCommand({
        SecretId: SECRETS_MANAGER_SECRET,
        SecretString: payload
      }));
    } else {
      // No storage configured; nothing to do
    }
    return true;
  },

  async revertCredentials(updatedCreds) {
    // Delete the login profile created during rotation
    try {
      await iamClient.send(new DeleteLoginProfileCommand({ UserName: IAM_USER }));
    } catch (e) {
      if (e.name !== "NoSuchEntity") {
        throw e;
      }
    }
    return true;
  },

  async onComplete() {
    // No-op
    return true;
  },

  async onFail(error) {
    await sendSmsTopic(error.message || error.toString());
    return true;
  }
};
