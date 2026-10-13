'use-strict';

const { SecretsManagerClient, PutSecretValueCommand } = require('@aws-sdk/client-secrets-manager');
const { SNSClient, PublishCommand } = require('@aws-sdk/client-sns');
const { 
  RDSClient, 
  ModifyDBClusterCommand, 
  DescribeDBClustersCommand,
  ModifyDBInstanceCommand,
  DescribeDBInstancesCommand
} = require('@aws-sdk/client-rds');
const MODE = process.env.MODE || 'instance',
      modifyDb = MODE  => MODE == 'instance' ? ModifyDBInstanceCommand : ModifyDBClusterCommand,
      getDb = MODE => MODE == 'instance' ? DescribeDBInstancesCommand : DescribeDBClustersCommand,
      secretsClient = new SecretsManagerClient(),
      snsClient = new SNSClient(),
      rdsClient = new RDSClient(),
      ALERTS_TOPIC = process.env["ALERTS_TOPIC"],
      DRY_RUN = process.env["DRY_RUN"] === "true";

// Promisable settimeout
const sleep = ms => new Promise(res => setTimeout(() => res(), ms));
// Promise wrapper that removes the need for try/catch in an async func
const wrapper = (promise) => promise.then((data) => [undefined, data]).catch((err) => [err]);
const LOG_LEVEL = process.env['LOG_LEVEL'] || 'INFO';
// Faunceh little logger that supports debug, info, warn, and error in that order
const LOG_LEVELS = ['DEBUG', 'INFO', 'WARN'];
const log = (level, logs) => {
    LOG_LEVELS.indexOf(level) >= LOG_LEVELS.indexOf(LOG_LEVEL) && console.log(level, ...logs);
}
const logger = LOG_LEVELS.reduce((agg, level) => {
    return agg[level.toLocaleLowerCase()] = function() {log(level, arguments)}, agg;
}, {error: function() {console.error(...arguments)}});

/**
 * @summary - 
 * @param {Object} args - Args to pass to SNS 
 * @returns {undefined|Promise} - the result of the call to SNS if one was made
 */
const callSns = args => {
  return !DRY_RUN && args.TopicArn ? logger.info(args) : snsClient.send(new PublishCommand(args));
}

/**
  * @summary Returns the number of matches the regex finds in the string
  * @param {string} str 
  * @param {regex} reg 
  * @returns {number}
  */
const count = (str, reg) => (str.match(reg) || []).length;

/**
 * @summary - Generates a password of 20 characters with at least:
 *  2 lowercase characters
 *  2 uppercase characters
 *  2 numbers
 *  2 2 special characters
 * @returns string
 */
const generateNewPw = (length = 20) => {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%^&*?'
  while (true) {
    let pw = '';
    for (let i = 0; i < length; i++) {
      pw += characters[Math.round(Math.random()*(characters.length - 1))];
    }
    if (count(pw, /[a-z]/g) > 1 && count(pw, /[A-Z]/g) > 2 
      && count(pw, /[0-9]/g) > 1 && count(pw, /[!@#$%\^&*?]/g) > 2)
      return pw;
  }
}

/**
 * @summary - Updates the admin password for an RDS instance or cluster and saves the information to
 *              SecretsManager
 * @param {object} event - Lambda event that contains the needed information to update an RDS instance/cluster
 */
exports.handler = async ({mode, rdsIdentifier, rdsAdminInfoLocation, pwLength = 64}) => {
  try{
    if (!mode)
      throw new Error("Missing the DB mode from the input event: 'mode' field with values either 'instance' or 'cluster'");
    if (!rdsIdentifier)
      throw new Error("Missing the RDS Idenifier in the 'rdsIdentifier' field");
    if (!rdsAdminInfoLocation)
      throw new Error("Missing the SecretsManager location to store the new credentials in for the field 'rdsAdminInfoLocation'");

    logger.info('Starting process to update user password');
    logger.debug('Generating a new password')
    const pw = generateNewPw(pwLength);

    logger.info('Getting instance information');
    let { DBInstances, DBClusters } = await rdsClient.send(
      new getDb(mode)({
        DBInstanceIdentifier: rdsIdentifier,
        DBClusterIdentifier: rdsIdentifier
      })
    );
    logger.debug(DBInstances, DBClusters);
    const instance = DBInstances ? DBInstances[0] : DBClusters[0];

    logger.info('Updating the master db password');
    if (!DRY_RUN) {
      await rdsClient.send(
        new modifyDb(mode)({
          DBInstanceIdentifier: rdsIdentifier,
          DBClusterIdentifier: rdsIdentifier,
          MasterUserPassword: pw
        })
      );
    } else {
      logger.info('Skipping call to modify the database for dry run');
      await sleep(100);
    }
    
    logger.info('Saving the Password to Secrets Manager');
    if (!DRY_RUN) {
      logger.debug({
        username: instance.MasterUsername,
        password: '----',
        engine: instance.Engine,
        host: instance.Endpoint.Address || instance.Endpoint,
        port: instance.Port || instance.Endpoint.Port,
        dbInstanceIdentifier: rdsIdentifier
      })
      await secretsClient.send(new PutSecretValueCommand({
        SecretId: rdsAdminInfoLocation,
        SecretString: JSON.stringify({
          username: instance.MasterUsername,
          password: pw,
          engine: instance.Engine,
          host: instance.Endpoint.Address || instance.Endpoint,
          port: instance.Port || instance.Endpoint.Port,
          dbInstanceIdentifier: rdsIdentifier
        })
      }));
      await callSns({
        Message: `Succesfully updated the admin PW for the ${rdsIdentifier} environment.`,
        Subject: 'Successfully updated admin password',
        TopicArn: ALERTS_TOPIC,
      });
    } else {
      logger.info('Skipping call to modify the database for dry run');
      await sleep(100);
    }
    logger.info('Done');
  } catch (err) {
    logger.error(err);
    await callSns({
      Message: `Failed to update the admin PW for the ${rdsIdentifier} environment.`,
      Subject: "Error updating admin password",
      TopicArn: ALERTS_TOPIC,
    });
    throw err;
  } 
};
