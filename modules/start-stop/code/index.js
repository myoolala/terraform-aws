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
const {
    AutoScalingClient,
    DescribeAutoScalingGroupsCommand,
    UpdateAutoScalingGroupCommand
} = require('@aws-sdk/client-auto-scaling');
const {
    RDSClient,
    DescribeDBInstancesCommand,
    ListTagsForResourceCommand,
    StartDBInstanceCommand,
    StopDBInstanceCommand,
} = require("@aws-sdk/client-rds");
const rdsClient = new RDSClient();
const ecsClient = new ECSClient();
const ec2Client = new EC2Client();
const eventBridgeClient = new EventBridgeClient();
const asgClient = new AutoScalingClient();
const TAG_LOOKUP = process.env['TAG_LOOKUP'] || 'ServiceRunSchedule';
const DRY_RUN = process.env['DRY_RUN'] === 'true';
const START_GRACE_IN_HOURS = parseInt(process.env['START_GRACE_IN_HOURS'] || 2);

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
    const [callThis, ...args] = arguments;
    logger.debug('Making a call to edit an AWS resources', callThis, args);
    if (DRY_RUN) {
        logger.warn('Dry Run mode enabled, skipping the call');
        return sleep(100);
    }
    logger.debug('Calling AWS');
    return callThis(...args);
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

/**
 * @summary Given a schedule and state, returns what should be done to achieve the desired state
 * @param {string} schedule - Schedule to use for the time check
 * @param {Date} timeStamp - The timestamp to check against the schedule 
 * @param {string} state - The current state of the system to use to determine what to do
 * @returns {string<up|down|no>} - up means scale up, down means scale down, and no means do nothing
 */
const getDecision = (schedule, timeStamp, state) => {
    // Parse the tag to find out when the service should be scaled up
    let [days, start, end] = schedule.split('/');
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
    logger.debug('Starting process to check ECS Services');
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
            
            // Ignore any servie that doesn't have the scaling tag
            if (!tags[TAG_LOOKUP] || !tags[TAG_LOOKUP].length) {
                logger.info(`${service.serviceName} doesn't have the relatant tags, skipping`);
                continue;
            }

            const decision = getDecision(tags[TAG_LOOKUP], timeStamp, service.desiredCount ? 'up' : 'down');

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

    logger.debug('EC2 list instances response: ', data);
    // Filter out instances that do not care about money
    instances = instances.filter(instance => {
        return !!instance.Tags.filter(tag => tag.Key === TAG_LOOKUP).length
    });
    logger.debug('Filtered down EC2 instances: ', instances);

    // Group the instances by required actions
    let instancesToStop = [];
    let instancesToStart = [];
    for (let instance of instances) {
        logger.debug('Checking instance: ', instance.InstanceId);
        const tags = instance.Tags.reduce((agg, {Key, Value}) => (agg[Key] = Value, agg), {});
        logger.debug('Found tags: ', tags);
        let decision = getDecision(tags[TAG_LOOKUP], timeStamp, instance.State.Name === 'running' ? 'up' : 'down'); 
        logger.debug('For the instance the decision is: ', decision);

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
const handleAsg = async timeStamp => {
    logger.debug('Starting process to check AutoScaling groups');

    // Go get all of the instances, we really only need to get the id's and tags
    let [err, data] = await wrapper(asgClient.send(new DescribeAutoScalingGroupsCommand({
        MaxRecords: 100,
        Filters: [{
            Name: "tag-key",
            Values: [
                TAG_LOOKUP,
            ],
        }]
    })));
    if (err)
        return logger.error(err)
    
    let groups = data.AutoScalingGroups;
    while (data.NextToken) {
        [err, data] = await wrapper(asgClient.send(new DescribeAutoScalingGroupsCommand({
            MaxRecords: 100,
            Filters: [{
                Name: "tag-key",
                Values: [
                    TAG_LOOKUP,
                ],
            }],
            NextToken: data.NextToken
        })));
        if (err)
            return logger.error(err)
        groups.push(...data.AutoScalingGroups);
    }
    logger.debug('Found AS Groups: ', groups);

    for (let asg of groups) {
        logger.debug('Checking the group: ', asg);

        const state = asg.DesiredCapacity > asg.MinSize ? 'up' : 'down';
        const tags = asg.Tags.reduce((agg, {Key, Value}) => (agg[Key] = Value, agg), {});
        logger.debug('Found ASG tags: ', tags)
        let decision = getDecision(tags[TAG_LOOKUP], timeStamp, state);
        logger.debug(`Got decision ${decision} for the asg: `, tags[TAG_LOOKUP], timeStamp, state);

        if (decision === 'down') {
            logger.info(`Scaling down the ASG ${asg.AutoScalingGroupName}`);
            await callService(asgClient.send.bind(asgClient), new UpdateAutoScalingGroupCommand({
                AutoScalingGroupName: asg.AutoScalingGroupName,
                DesiredCapacity: Math.min(asg.MinSize, asg.DesiredCapacity - 1)
            }));
        } else if (decision === 'up') {
            logger.info(`Scaling up the ASG ${asg.AutoScalingGroupName}`);
            await callService(asgClient.send.bind(asgClient), new UpdateAutoScalingGroupCommand({
                AutoScalingGroupName: asg.AutoScalingGroupName,
                DesiredCapacity: Math.max(asg.MaxSize, asg.DesiredCapacity + 1)
            }));
        } else {
            logger.debug('Doing nothing for the ASG ' + asg.AutoScalingGroupName);
        }
    }
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

    logger.debug('Found these rules to check: ', rules);

    for (let rule of rules) {
        const schedule = rule.Description.split(" --- ");
        logger.debug('Found schedule for cron: ', rule.Name, schedule[1]);
        logger.debug(rule.Description.split(" --- "));
        if (schedule.length < 2)
            continue
        logger.debug('Making decision for Cron schedule');
        let decision = getDecision(schedule[1], timeStamp, rule.State === 'ENABLED' ? 'up' : 'down');
        logger.debug('Cron decision is ', decision);

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

/**
 * @summary Scans RDS DB instances in the current region and starts/stops them based on schedule tags
 * @returns {Promise<void>}
 */
const handleRdsInstances = async timeStamp => {
    logger.info("Starting process to check RDS DB instances");

    let [err, data] = await wrapper(rdsClient.send(new DescribeDBInstancesCommand({
        MaxRecords: 100
    })));

    if (err)
        return logger.error(err);

    let instances = data.DBInstances ?? [];

    while (data.Marker) {
        [err, data] = await wrapper(rdsClient.send(new DescribeDBInstancesCommand({
            MaxRecords: 100,
            Marker: data.Marker
        })));

        if (err)
            return logger.error(err);

        instances.push(...(data.DBInstances ?? []));
    }

    logger.info("Found these RDS instances to check: ", instances.map(i => i.DBInstanceIdentifier));

    for (const instance of instances) {
        const instanceId = instance.DBInstanceIdentifier;
        const instanceArn = instance.DBInstanceArn;
        const status = instance.DBInstanceStatus;

        logger.info("Checking RDS instance:", instanceId, status);

        const [tagErr, tagData] = await wrapper(rdsClient.send(new ListTagsForResourceCommand({
            ResourceName: instanceArn
        })));

        if (tagErr) {
            logger.error(`Failed to get tags for RDS instance ${instanceId}`, tagErr);
            continue;
        }

        const tags = tagData.TagList ?? [];

        const scheduleTag = tags.find(tag => tag.Key === "Schedule");

        if (!scheduleTag?.Value) {
            logger.info(`No Schedule tag found for RDS instance ${instanceId}, skipping`);
            continue;
        }

        logger.info("Found schedule for RDS instance:", instanceId, scheduleTag.Value);

        const currentState = status === "available" ? "up" : "down";

        const decision = getDecision(scheduleTag.Value, timeStamp, currentState);

        logger.info("RDS decision is", decision);

        if (decision === "up") {
            if (status === "available") {
                logger.info(`RDS instance ${instanceId} is already available`);
                continue;
            }

            if (status !== "stopped") {
                logger.info(`RDS instance ${instanceId} is not stopped, current status is ${status}, skipping start`);
                continue;
            }

            await callService(
                rdsClient.send.bind(rdsClient),
                new StartDBInstanceCommand({
                    DBInstanceIdentifier: instanceId
                })
            );
        } else if (decision === "down") {
            if (status === "stopped") {
                logger.info(`RDS instance ${instanceId} is already stopped`);
                continue;
            }

            if (status !== "available") {
                logger.info(`RDS instance ${instanceId} is not available, current status is ${status}, skipping stop`);
                continue;
            }

            await callService(
                rdsClient.send.bind(rdsClient),
                new StopDBInstanceCommand({
                    DBInstanceIdentifier: instanceId
                })
            );
        }
    }
};

exports.handler = async event => {
    logger.debug('Incoming event: ', event);

    // Time stamp to check against for scaling options
    const timeStamp = new Date();
    logger.info('Time stamp to check against: ', timeStamp);

    const result = await Promise.allSettled([
        handleEcs(timeStamp),
        handleEc2(timeStamp),
        handleCrons(timeStamp),
        handleAsg(timeStamp),
        handleRdsInstances(timeStamp)
    ]);
    logger.debug(result);
}