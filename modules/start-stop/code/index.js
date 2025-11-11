'use-strict';
const LOG_LEVEL = process.env['LOG_LEVEL'] || 'INFO';
const { 
    ECSClient, 
    ListClustersCommand,
    ListServicesCommand,
    DescribeServicesCommand,
    UpdateServiceCommand
} = require('@aws-sdk/client-ecs');
const { 
    EC2Client, 
    DescribeInstancesCommand,
    StopInstancesCommand
} = require("@aws-sdk/client-ec2");
const { 
    EventBridgeClient, 
    ListRulesCommand,
    PutRuleCommand
} = require("@aws-sdk/client-eventbridge");
const ecsClient = new ECSClient();
const ec2Client = new EC2Client();
const eventBridgeClient = new EventBridgeClient();
const TAG_LOOKUP = process.env['TAG_LOOKUP'] || 'ServiceRunTime';
const DRY_RUN = process.env['DRY_RUN'] === 'true';
const START_GRACE_IN_HOURS = int(process.env['START_GRACE_IN_HOURS'] || 2);

// Promise wrapper that removes the need for try/catch in an async func
const wrapper = promise => Promise.resolve(promise).then((data) => [undefined, data]).catch((err) => [err]);
// Promisable settimeout
const sleep = ms => new Promise(res => setTimeout(() => res(), ms));

// Faunceh little logger that supports debug, info, warn, and error in that order
const LOG_LEVELS = ['DEBUG', 'INFO', 'WARN'];
const log = (level, logs) => {
    LOG_LEVELS.indexOf(level) >= LOG_LEVELS.indexOf(LOG_LEVEL) && console.log(level, ...logs);
}
const logger = LOG_LEVELS.reduce((agg, level) => {
    return agg[level.toLocaleLowerCase()] = function() {log(level, arguments)}, agg;
}, {error: function() {console.error(...arguments)}});

/**
 * @summary - give a time in the format of "HH:mm" returns a date object 
 *  with the same time for today and zero'd seconds
 * @param {string} time  - time in hours and minutes to use
 * @returns {Date} - With with the hours and minutes set
 */
const getTime = time => {
    const [hour, min] = time.split(':');
    time = new Date();
    time.setHours(parseInt(hour));
    time.setMinutes(parseInt(min));
    time.setSeconds(0);
    return time;
}

const callService = function() {
    if (DRY_RUN) {
        logger.warn('Dry Run mode enabled, skipping the calling: ', arguments[0], arguments.slice(1));
        return sleep(100);
    }
    return arguments[0](...arguments.slice(1));
}

/**
 * @summary - Scales a fargate service to the desired size, however blocks the action when the 
 *              dryrun mode is enabled
 * @param {string} cluster - arn of the ecs cluster
 * @param {string} service - arn of the ecs service
 * @param {number} desiredCount - new desired count
 * @returns 
 */
const scaleService = (cluster, service, desiredCount) => {
    return callService(ecsClient.send.bind(ecsClient), new UpdateServiceCommand({
        cluster,
        service,
        desiredCount,
        forceNewDeployment: true
    }));
}

/**
 * @summary - Converts a day expression into individual days in an array for lookups
 * @param {string} days - day expression to decode
 * @returns {List<string>} - Array of days based on the expression 
 */
const getDays = days => {
    if (days === '*') days = '1,2,3,4,5,6,7';
    else if (days.indexOf('-') > -1) {
        let [start, end] = days.split('-');
        start = parseInt(start);
        end = parseInt(end);
        days = [];
        for (; start <= end; start++) days.push(`${start}`);
        days = days.join(',');
    }
    const toReturn = days.split(',').map(num => parseInt(num));
    logger.debug(toReturn);
    return toReturn;
}

const getDecision = (schedule, timeStamp, state) => {
    // Parse the tag to find out when the service should be scaled up
    [days, start, end] = schedule.split('/');
    logger.debug(days, start, end);
    days = getDays(days);
    let startBuffer = parseInt(start.split(':')[0]) - START_GRACE_IN_HOURS;
    startBuffer = `${startBuffer}:${start.split(':')[1]}`;
    startBuffer = getTime(startBuffer.length == 5 ? startBuffer : '0' + startBuffer);
    end = getTime(end);

    logger.info(timeStamp, start, startBuffer, end, days, timeStamp.getDay() + 1);

    if (start != 'no' && days.indexOf(timeStamp.getDay() + 1) >= 0 
        && timeStamp.valueOf() < end.valueOf()
        && timeStamp.valueOf() >= getTime(start).valueOf()) {
        // If so check if we even need to scale and do so if we do
        if (state === 'down') {
            return 'up';
        } else {
            logger.debug('Service already scaled up');
            return 'no';
        }
    }
    // No need to check if we should scale down based on time since the first if guarantees it
    // However if the time is after the start of the grace period don't shut it down
    // This allows early birds to be early and a bird
    else if (
        timeStamp.valueOf() < startBuffer.valueOf()
        || timeStamp.valueOf() > end.valueOf()
    ) {
        if (state === 'up') {
            return 'down';
        } else {
            logger.debug('Service already scaled down');
            return 'no'
        }
    } else {
        logger.debug('Nothing to do');
    }
    return 'no';
}

/**
 * @summary: Scans through ECS in the current region and scales services based on tags
 * @returns {Promise<void>} - A promise signifying completion of the task
 */
const handleEcs = async timeStamp => {
    // Get all the clusters for the region
    const clusters = await ecsClient.send(new ListClustersCommand({
        maxResults: 100
    }));
    logger.debug('Found clusters: ', clusters.clusterArns);
    
    // Cycle through the clusters to get all the services
    for (let cluster of clusters.clusterArns) {
        logger.info(`Querying ${cluster} for services`);
        const services = await ecsClient.send(new ListServicesCommand({
            cluster,
            maxResults: 100
        }));
        
        logger.debug('Found Services: ', services.serviceArns);
        // Pull the tag info for the service
        const serviceInfo = await ecsClient.send(new DescribeServicesCommand({
            cluster,
            services: services.serviceArns,
            include: ['TAGS']
        }));

        logger.debug('Found Service information: ', serviceInfo.services);
        for (let service of serviceInfo.services) {
            logger.debug(`Checking ${service.serviceArn} to see if there is anything to do`);
            const tags = service.tags.reduce((agg, {key, value}) => (agg[key] = value, agg), {});
            logger.debug('Tags found: ', tags);
            
            let end, start, days;
            // Ignore any servie that doesn't have the scaling tag
            if (!tags[TAG_LOOKUP] || !tags[TAG_LOOKUP].length) {
                logger.info(`${service.serviceName} doesn't have the relatant tags, skipping`);
                continue;
            }

            const decision = getDecision(tags[TAG_LOOKUP], timeStamp);

            if (decision === 'up') {
                logger.info(`Scaling up ${service.serviceName}`);
                await scaleService(cluster, service.serviceArn, 1);
            } else if (decision === 'down') {
                logger.info(`Scaling down ${service.serviceName}`);
                await scaleService(cluster, service.serviceArn, 0);
            }
        }
    }
}

/**
 * @summary: Scans through EC2 instances in the current region and starts/stops based on tags
 * @returns {Promise<void>} - A promise signifying completion of the task
 */
const handleEc2 = async timeStamp => {
    logger.debug('Starting process to check EC2 instances');

    // Go get all of the instances, we really only need to get the id's and tags
    let [err, data] = await wrapper(ec2Client.send(new DescribeInstancesCommand({
        MaxResults: 100
        // @TODO: only have the desired fields returned
    })));
    if (err)
        return logger.error(err)

    let instances = data.Reservations.map(({Instances}) => Instances).flat();
    while (data.NextToken) {
        [err, data] = await wrapper(ec2Client.send(new DescribeInstancesCommand({
            MaxResults: 100,
            NextToken: data.NextToken
        })));
        if (err)
            return logger.error(err)
        instances.push(...data.Reservations.map(({Instances}) => Instances).flat());
    }

    logger.debug(data);
    // Filter out instances that do not care about money
    instances = instances.filter(instance => {
        return !!instance.Tags.filter(tag => tag.Key === TAG_LOOKUP).length
    });
    logger.debug(instances);

    // Group the instances by required actions
    let instancesToStop = [];
    let instancesToStart = [];
    for (let instance of instances) {
        const tags = instance.Tags.reduce((agg, {key, value}) => (agg[key] = value, agg), {});
        let decision = getDecision(tags[TAG_LOOKUP], timeStamp); 

        if (decision === 'up') {
            instancesToStart.push(instance.InstanceId);
        } else if (decision === 'down') {
            instancesToStop.push(instance.InstanceId);
        }
    }

    // Perform the update
    // @TODO: this probably won't scale well if there are thousands of servers....
    // But this is mainly meant for a dev environment
    if (instancesToStop.length) {
        logger.info(`There are ${instancesToStop.lenght} instances to stop`);
        logger.debug(instancesToStop);
        await callService(ec2Client.send.bind(ec2Client), new StopInstancesCommand({
            InstanceIds: instancesToStop
        }));
    }
    if (instancesToStart.length) {
        logger.info(`There are ${instancesToStart.lenght} instances to start`);
        logger.debug(instancesToStart);
        await callService(ec2Client.send.bind(ec2Client), new StopInstancesCommand({
            InstanceIds: instancesToStart
        }));
    }
}

/**
 * @summary: Scans through EC2 AutoScaling groups in the current region and scales based on tags
 * @returns {Promise<void>} - A promise signifying completion of the task
 */
const handleAsg = async () => {
}

/**
 * @summary: Scans through CloudWatch Rules in the current region and activates/deactivated based on tags
 * @returns {Promise<void>} - A promise signifying completion of the task
 */
const handleCrons = async timeStamp => {
    logger.debug('Starting process to check EventBridge rules');

    // Go get all of the instances, we really only need to get the id's and tags
    let [err, data] = await wrapper(eventBridgeClient.send(new ListRulesCommand({
        Limit: 100
    })));
    if (err)
        return logger.error(err)

    let rules = data.Rules;
    while (data.NextToken) {
        [err, data] = await wrapper(eventBridgeClient.send(new ListRulesCommand({
            Limit: 100,
            NextToken: data.NextToken
        })));
        if (err)
            return logger.error(err)
        rules.push(...data.Rules);
    }

    logger.debug(rules);

    for (let rule of rules) {
        const schedule = rule.Description.split(" --- ")[-1];
        if (!schedule)
            continue
        let decision = getDecision(schedule, timeStamp, rule.State === 'ENABLED' ? 'up' : 'down');

        if (decision === 'up') {
            await callService(eventBridgeClient.send.bind(eventBridgeClient), new PutRuleCommand({
                Name: rule.name,
                State: "ENABLED"
            }));
        } else if (decision === 'down') {
            await callService(eventBridgeClient.send.bind(eventBridgeClient), new PutRuleCommand({
                Name: rule.name,
                State: "DISABLED"
            }));
        }
    }
}

exports.handler = async event => {
    logger.debug(event);

    // Time stamp to check against for scaling options
    const timeStamp = new Date();

    await Promise.all([
        wrapper(handleEcs(timeStamp)),
        wrapper(handleEc2(timeStamp)),
        wrapper(handleCrons(timeStamp)),
        wrapper(handleAsg(timeStamp))
    ]);
}