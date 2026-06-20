'use-strict';

const net = require('net'),
      util = require('node:util'),
      zlib = require('node:zlib'),
      gzip = util.promisify(zlib.gzip),
      BUCKET = process.env['BUCKET'],
      PREFIX = process.env['PREFIX'].replace(/\/+$/, '').replace(/^\//, ''),
      LOG_LEVEL = (process.env['LOG_LEVEL'] || 'INFO').toLocaleLowerCase(),
      ONE_WEEK = 60 * 60 * 24 * 7,
      FOUR_WEEKS = 60 * 60 * 24 * 7 * 4,
      SERVER_CACHE_MS = process.env['SERVER_CACHE_MS'] || 1000 * 60 * 5,
      SPA_ENABLED = process.env['SPA_ENABLED'] === 'enabled',
      DEFAULT_FILE_PATH = process.env['DEFAULT_FILE_PATH'],
      ENABLE_PRE_SIGNED_URLS = process.env['ENABLE_PRE_SIGNED_URLS'] === 'true',
      // 2^20 Bytes is 1MB
      MAX_PAYLOAD_RESPONSE = Math.pow(2,20),
      GZIP_MIN_LENGTH = parseInt(process.env.GZIP_MIN_LENGTH || '1024'),
      CACHE_GZIP_ENABLED = (process.env.CACHE_GZIP_ENABLED || 'true') === "true",
      DEFAULT_RESPONSE_HEADERS = process.env['DEFAULT_RESPONSE_HEADERS'] ? JSON.parse(process.env['DEFAULT_RESPONSE_HEADERS']) : {},
      metricsConfig = process.env['METRICS_CONFIG'] ? JSON.parse(process.env['METRICS_CONFIG']) : {enabled: false};

const { S3Client, GetObjectCommand } = require('@aws-sdk/client-s3'),
      client = new S3Client(),
      w = promise => promise.then(data => [undefined, data]).catch(err => [err]),
      LOG_LEVELS = ['debug', 'info', 'warn'],
      log = (level, logs) => {
          LOG_LEVELS.indexOf(level.toLocaleLowerCase()) >= LOG_LEVELS.indexOf(LOG_LEVEL) && console.log(level, ...logs);
      },
      logger = LOG_LEVELS.reduce((agg, level) => {
          return agg[level.toLocaleLowerCase()] = function() {log(level, arguments)}, agg;
      }, {error: function() {console.error(...arguments)}});

let CACHE_MAPPING = process.env['CACHE_MAPPING'];
if (CACHE_MAPPING && CACHE_MAPPING.length) {
    try {
        CACHE_MAPPING = JSON.parse(process.env['CACHE_MAPPING']);
        // Any field that is not a string will cause the ALB to through a 502
        for (let fileType of Object.keys(CACHE_MAPPING)) {
            CACHE_MAPPING[fileType] = `${CACHE_MAPPING[fileType]}`;
        }
    } catch (err) {
        logger.error('Unable to parse provided cache mapping', err);
        CACHE_MAPPING = undefined;
    }
}
const isFileRequest = /\/[^\/]+\.[a-zA-Z]+$/;
 
// The default cache mapping
CACHE_MAPPING = CACHE_MAPPING || {
    'font/ttf': `${FOUR_WEEKS}`,
    'image/png': `${FOUR_WEEKS}`,
    'image/jpeg': `${FOUR_WEEKS}`,
    'text/plain': `${FOUR_WEEKS}`,
    'font/woff2': `${FOUR_WEEKS}`,
    'applications/pdf': `${FOUR_WEEKS}`,
    'text/css': `${ONE_WEEK}`,
    'text/javascript': `${ONE_WEEK}`,
    'application/json': `${ONE_WEEK}`,
    'application/javascript': `${ONE_WEEK}`,
    'application/manifest+json': `${ONE_WEEK}`,
}

/**
 * @summary - Ouputs an embedded cloudwatch log to create a metric for the request for the domain
 * @param {string} host - host domain that was hit
 * @returns {void}
 */
const createHostHitMetric = (host) => {
    if(!metricsConfig.enabled) return;
    if (!host) return logger.error('No host provided to createHostHitMetric');
    if (net.isIP(host) !== 0) return logger.warn(`Not invoked with a domain but instead an IP "${host}", ignoring metric`);

    // Console log here to make sure our logs are perfect
    console.log(JSON.stringify({
        "_aws": {
          "Timestamp": new Date().valueOf(), // Unix timestamp in milliseconds
          "CloudWatchMetrics": [
            {
              "Namespace": metricsConfig.namespace,
              "Dimensions": [["host"]],
              "Metrics": [
                {
                  "Name": "RequestCount",
                  "Unit": "Count"
                }
              ]
            }
          ]
        },
        // Custom properties used as metrics or dimensions
        "host": host,
        "RequestCount": 1
    }));
}

/**
 * @summary - Converts input data into an ALB response object
 * @param {string} body - data payload to return. Limit 1MB
 * @param {Object} headers - <Optional> Headers to return in the resposne
 * @param {Number} statusCode - <Optional> Status code for the response
 * @param {Boolean} isBase64Encoded - <Optional> Is the payload base64 encoded
 * @returns {Object} - ALB response object
 */
const mapResponse = (body, headers = {}, statusCode = 200, isBase64Encoded = false) => ({
    statusCode,
    statusDescription: statusCode + ' ' + (statusCode === 200 ? 'ok' : 'not ok'),
    isBase64Encoded,
    headers,
    body
});

/**
 * @summary - Returns the time to have the client cache a file
 * @param {string} type - Content type to match to a cache time
 * @returns {string} - Time in seconds to cache a file in the browser
 */
const getCacheHeader = type =>  CACHE_MAPPING[type] ? `max-age=${CACHE_MAPPING[type]}` : undefined;

/**
 * @summary - Runs s3 get on the options
 * @param {object} options - S3 Get Object options
 * @returns {Promise<Object>} - S3 Get Objcet resposne
 */
const s3Get = async options => client.send(new GetObjectCommand(options));

// Keep this in global scope as that will allow it to be shared across invocations within the runtime
const cache = {};

/**
 * @summary - Runs an S3 GetObject command but first checks the in memory cache to see if the file is available
 * @param {String} Key - Path in the S3 bucket to retreive
 * @param {boolean} override - Skip and forcibly update the in memory cache
 * @returns {Object} - S3 response and body payload of the s3 file
 */
const getAndCache = async (Key, override = false) => {
    logger.debug(`Checking cache for "${Key}"`);
    if (!override && cache[Key] && new Date().valueOf() - cache[Key].time <= SERVER_CACHE_MS) {
        logger.debug('Returning cached version');
        return {
            file: cache[Key].file,
            body64: cache[Key].body64,
            gzipBody64: cache[Key].gzipBody64,
            gzipReady: cache[Key].gzipReady
        }
    }

    logger.debug(`Returning the S3 version of ${BUCKET} and ${Key}`);
    // @TODO: add logic to cache 404 requests
    let file = await s3Get({Bucket: BUCKET, Key});
    logger.debug('Got file object:', file)
    let bodyBuffer = await file.Body.transformToByteArray();
    let body64 = Buffer.from(bodyBuffer).toString('base64');
    let gzipBody64 = gzip(Buffer.from(bodyBuffer)).then(b => b.toString('base64'));
    logger.debug('Converted body to base64', body64.length);
    
    // Mark that this is ready to be served
    // Also funny quirk, this feels like you would make a request, cache it, wait 5s
    // then make it again and get the gzip version but that's not actually the case
    // This is because any background promise or logic that happens inbetween any invocation
    // is completely paused along with the event loop so you have to wait for the background
    // process to finish while the lambda is actively invoked
    gzipBody64.then(() => {cache[Key].gzipReady = true;})

    // Update the cache with the new data
    cache[Key] = {
        file,
        body64,
        gzipReady: false,
        gzipBody64,
        time: new Date().valueOf()
    };

    return {file, body64, gzipBody64}
}

const fourOhFour = mapResponse('{"message": "Not Found"}', {'Content-Type': 'application/json'}, 404);

let getSignedUrl = undefined;
const generateSignedUrl = (Key) => {
    // Basically, this should be rare so don't load this library unless needed
    if (!getSignedUrl) {
        getSignedUrl = require('@aws-sdk/s3-request-presigner').getSignedUrl;
    }

    const command = new GetObjectCommand({
        Bucket: BUCKET,
        Key,
    });
    
    return getSignedUrl(client, command, { expiresIn: 300 });
}

exports.handler = async event => {
    logger.debug(JSON.stringify(event));

    // Only accept Gets and POSTs
    // Posts allow us to support SAML responses if the app isn't using # based routing
    if (event.httpMethod != 'GET' && event.httpMethod != 'POST') {
        logger.debug(`Invalid method "${event.httpMethod}" was given`)
        return mapResponse('STAHP!!', {}, 405);
    }

    createHostHitMetric(event.headers.host);

    // If the key is the root, assume it's index.html
    let Key = PREFIX + (event.path.endsWith('/') ? event.path + 'index.html' : event.path);

    // Check if the using is busting cache, like by hitting the refresh button
    const bustCache = event.headers['cache-control'] === 'no-cache' || event.headers['max-age'] === '0';
    logger.debug(`Cache will${bustCache ? '' : ' not'} be busted`);

    logger.debug('Checking for Key: ', Key);
    let [err, cacheObject] = await w(getAndCache(Key, bustCache));

    // If there is an error, assume it was a 404 for a single page request
    // @TODO: this needs to look and check if there is a file extension, don't do the index.html for that
    if (err) {
        logger.debug('Failed to find the file:', Key);
        if (!SPA_ENABLED || isFileRequest.test(event.path)) {
            logger.debug(err)
            return fourOhFour;
        }
        
        logger.debug('SPA mode enabled, returning default file');
        [err, cacheObject] = await w(getAndCache(PREFIX + '/' + DEFAULT_FILE_PATH, bustCache));

        if (err) {
            logger.error('Failed to find the default file', err);
            return fourOhFour;
        }
        Key = PREFIX + '/' + DEFAULT_FILE_PATH;
    }

    
    const {file, body64, gzipReady, gzipBody64} = cacheObject;
    const couldSupportGzip = CACHE_GZIP_ENABLED
          && body64.length >= GZIP_MIN_LENGTH 
          && (event.headers['accept-encoding'] || '').indexOf('gzip') > -1;
    // Basically, if the GZIP for a large file isn't done gzipping, don't wait unless we need
    // to. The large GZIP's take a while on small lambdas
    const startWithGzip = couldSupportGzip && gzipReady;
    logger.debug(
        'gzip args: ',
        CACHE_GZIP_ENABLED,
        body64.length,
        GZIP_MIN_LENGTH,
        (event.headers['accept-encoding'] || '').indexOf('gzip') > -1,
        couldSupportGzip,
        gzipReady,
        startWithGzip
    );

    logger.debug(`Planning to return ${startWithGzip ? 'gzip\'d' : 'raw'} version`);
    logger.debug('Returining file contents size: ', body64.length);
    // Maybe this is a gzip maybe it's not, who cares
    let toReturn = mapResponse(startWithGzip ? await gzipBody64 : body64, {
        ...DEFAULT_RESPONSE_HEADERS,
        ...{
            // No idea why, but s3 return the content type of the gz but the ui show's it as type gzip
            'Content-Type': file.ContentType, 
            // This tells the browser to unpack the gzip files
            'Content-Encoding': startWithGzip ? 'gzip' : undefined, 
            // Set the cache
            'cache-control': getCacheHeader(file.ContentType)
        }
    }, 200, true);

    // But if it's not a gzip and was too big and could be a gzip, wait for the gzip and return that
    if (Buffer.byteLength(JSON.stringify(toReturn)) > MAX_PAYLOAD_RESPONSE && couldSupportGzip && !gzipReady) {
        logger.debug('Raw version response too large, attempting a gzip response');
        // I do wonder if we can skip the gzip wait and just know..... because the gzip can take a while
        // and waiting for it to compress to just not use it seems wasteful along with a waste of memory....
        // well crap, didn't think about running out of memory.... especially since we save two files now
        toReturn = mapResponse(await gzipBody64, {
            ...DEFAULT_RESPONSE_HEADERS,
            ...{
                // No idea why, but s3 return the content type of the gz but the ui show's it as type gzip
                'Content-Type': file.ContentType, 
                // This tells the browser to unpack the gzip files
                'Content-Encoding': 'gzip',
                // Set the cache
                'cache-control': getCacheHeader(file.ContentType)
            }
        }, 200, true);
    }
    
    if (Buffer.byteLength(JSON.stringify(toReturn)) > MAX_PAYLOAD_RESPONSE) {
        // If it's still too big, give up and go play checkers or something idk my bff rose
        if (!ENABLE_PRE_SIGNED_URLS) {
            logger.error(`Request response ${event.path} exceeds max allowed size`);
            return mapResponse('Internal server error', {'Content-Type': 'text/html'}, 500); 
        }
        
        // Basically a last hale merry. In a perfect world this should never happen and instead
        // either a s3 url in a public bucket is used or we have switched to a real server
        toReturn = mapResponse('', {'Location': await generateSignedUrl(Key)}, 302);
    }
    
    // Return the response with the default headers merged and overwritten by the content headers
    logger.debug('Returning response', toReturn);
    return toReturn
}