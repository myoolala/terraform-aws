'use-strict';
process.env['AWS_PROFILE'] = 'ra-govcloud';
process.env['AWS_REGION'] = 'us-gov-east-1';
process.env['DRY_RUN'] = 'true';
process.env['LOG_LEVEL'] = process.argv[2] || 'DEBUG';

require('./index.js').handler({}).then(() => {
    console.log('Done');
    process.exit(0);
}, err => {
    console.error('There was an error', err);
    process.exit(1);
})