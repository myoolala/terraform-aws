import { handler } from './index.mjs';
import { IAMClient } from '@aws-sdk/client-iam';
import { RDSClient } from '@aws-sdk/client-rds';
import { SecretsManagerClient } from '@aws-sdk/client-secrets-manager';
import { SSMClient } from '@aws-sdk/client-ssm';

// Set environment variables for deterministic config
process.env.passwordType = 'IAM_USER_ACCESS_TOKEN';
process.env.secretStore = 'secretsmanager';
process.env.secretStoreLocation = 'arn:aws:secretsmanager:us-east-1:123456789012:secret:test-secret';
process.env.secretLocation = 'arn:aws:iam::123456789012:user/test-iam-user';

// Mock responses
const mockResponses = {
  CreateAccessKeyCommand: { AccessKey: { AccessKeyId: 'AKIA_NEW', SecretAccessKey: 'NEW_SECRET' } },
  ListAccessKeysCommand: { AccessKeyMetadata: [ { AccessKeyId: 'AKIA_OLD1', Status: 'Active' }, { AccessKeyId: 'AKIA_OLD2', Status: 'Active' } ] },
  UpdateAccessKeyCommand: {},
  DeleteAccessKeyCommand: {},
  PutSecretValueCommand: {},
  GetSecretValueCommand: {},
  PutParameterCommand: {},
};

function mockSendPrototype(ctor) {
  const originalSend = ctor.prototype.send;
  ctor.prototype.send = async function (command) {
    const name = command.constructor.name;
    const resp = mockResponses[name];
    if (!resp) throw new Error(`No mock response for ${name}`);
    await new Promise((r) => setTimeout(r, 10));
    return resp;
  };
  return () => { ctor.prototype.send = originalSend; };
}
const restoreIam = mockSendPrototype(IAMClient);
const restoreRds = mockSendPrototype(RDSClient);
const restoreSm = mockSendPrototype(SecretsManagerClient);
const restoreSsm = mockSendPrototype(SSMClient);

(async () => {
  console.log('--- Running IAM access key rotation test ---');
  try {
    await handler({ secret_type: 'IAM_USER_ACCESS_TOKEN' });
    console.log('Test succeeded');
  } catch (e) {
    console.error('Test failed:', e);
  } finally {
    restoreIam();
    restoreRds();
    restoreSm();
    restoreSsm();
  }
})();
