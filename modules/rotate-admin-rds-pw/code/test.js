'use-strict';

process.env['DRY_RUN'] = 'true';
process.env['AWS_REGION'] = 'us-east-1';
process.env['LOG_LEVEL'] = 'DEBUG';
process.env['ALERTS_TOPIC'] = process.argv[4];

require('./index.js').handler({
    rdsIdentifier: process.argv[2],
    rdsAdminInfoLocation: process.argv[3]
}).then(() => {
    process.exit();
}, err => {
    console.error(err);
    process.exit(1);
});