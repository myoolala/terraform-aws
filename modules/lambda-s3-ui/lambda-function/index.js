'use-strict';

const BUCKET = process.env['BUCKET'],
      PREFIX = process.env['PREFIX'].replace(/\/+$/, ''),
      LOG_LEVEL = process.env['LOG_LEVEL'],
      GZ_ASSETS = process.env['GZ_ASSETS'] === 'true',
      ONE_WEEK = 60 * 60 * 24 * 7,
      FOUR_WEEKS = 60 * 60 * 24 * 7 * 4,
      CACHE_MAPPING = process.env['CACHE_MAPPING'] ? JSON.parse(process.env['CACHE_MAPPING']) : {
          'font/ttf': FOUR_WEEKS,
          'image/png': FOUR_WEEKS,
          'text/plain': FOUR_WEEKS,
          'font/woff2': FOUR_WEEKS,
          'applications/pdf': FOUR_WEEKS,
          'text/css': ONE_WEEK,
          'text/javascript': ONE_WEEK,
          'application/json': ONE_WEEK,
          'application/javascript': ONE_WEEK,
          'application/manifest+json': ONE_WEEK,
      },
      SERVER_CACHE_MS = process.env['SERVER_CACHE_MS'] || 1000 * 60 * 5,
      SPA_ENABLED = process.env['SPA_ENABLED'] === 'enabled',
      DEFAULT_FILE_PATH = process.env['DEFAULT_FILE_PATH'],
      DEFAULT_RESPONSE_HEADERS = process.env['DEFAULT_RESPONSE_HEADERS'] ? JSON.parse(process.env['DEFAULT_RESPONSE_HEADERS']) : {};

const { S3Client, GetObjectCommand } = require('@aws-sdk/client-s3'),
      client = new S3Client(),
      w = promise => promise.then(data => [undefined, data]).catch(err => [err]),
      LOG_LEVELS = ['debug', 'info', 'warn'],
      log = (level, logs) => {
          LOG_LEVELS.indexOf(level) >= LOG_LEVELS.indexOf(LOG_LEVEL) && console.log(level, ...logs);
      },
      logger = LOG_LEVELS.reduce((agg, level) => {
          return agg[level.toLocaleLowerCase()] = function() {log(level, arguments)}, agg;
      }, {error: function() {console.error(...arguments)}});

/**
 * @summary - Converts input data into an ALB response object
 * @param {string} body - data payload to return. Limit 1MB
 * @param {Object} headers - <Optional> Headers to return in the resposne
 * @param {Number} statusCode - <Optional> Status code for the response
 * @param {Boolean} isBase64Encoded - <Optional> Is the payload base64 encoded
 * @returns {Object} - ALB response object
 */
const mapS3Object = (body, headers = {}, statusCode = 200, isBase64Encoded = false) => ({
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
const getCacheHeader = type =>  CACHE_MAPPING[type];

/**
 * @summary - Runs s3 get on the options
 * @param {object} options - S3 Get Object options
 * @returns {Promise<Object>} - S3 Get Objcet resposne
 */
const s3Get = async options => client.send(new GetObjectCommand(options));

/**
 * @summary - Converts a file stream to a buffer
 * @param {stream} stream - File stream to convert to a string
 * @returns {string} - Stream converted to a string
 */
const streamToBuffer = async (stream) => {
    const chunks = [];
    for await (const chunk of stream) {
        chunks.push(typeof chunk === 'string' ? Buffer.from(chunk) : chunk);
    }
    return Buffer.concat(chunks);
}

// Keep this in global scope as that will allow it to be shared across invocation
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
            body: cache[Key].body
        }
    }

    logger.debug('Returning the S3 version');
    let file = await s3Get({BUCKET, Key});
    let bodyBuffer = await streamToBuffer(file.body);
    let body = bodyBuffer.toString('base64');

    // Update the cache with the new data
    cache[Key] = {
        file,
        body,
        time: new Date().valueOf()
    };

    return {file, body}
}

const fourOhFour = mapS3Object('{"message": "Not Found"}', {'Content-Type': 'application/json'}, 404);

exports.handler = async event => {
    logger.debug(JSON.stringify(event));

    // Only accept Gets and POSTs
    // Posts allow us to support SAML responses if the app isn't using # based routing
    if (event.httpMethod != 'GET' && event.httpMethod != 'POST') {
        logger.debug(`Invalid method "${event.httpMethod}" was given`)
        return mapS3Object('STAHP!!', {}, 405);
    }

    // If the key is the root, assume it's index.html
    let Key = PREFIX + (event.path == '/' ? '/index.html' : event.path);

    // Since browsers love gzip, added support for that especially since the max response payload
    // size at the of 1MB
    if (GZ_ASSETS) Key += '.gz';

    // Check if the using is busting cache, like by hitting the refresh button
    const bustCache = event.headers['cache-control'] === 'no-cache' || event.headers['max-age'] === '0';
    logger.debug(`Cache will${bustCache ? '' : ' not'} be busted`);

    logger.debug('Checking for Key: ', Key);
    let [err, cacheObject] = await w(getAndCache(Key, bustCache));

    // If there is an error, assume it was a 404 for a single page request
    if (err) {
        logger.debug('Failed to find the file:', Key);
        if (!SPA_ENABLED)
            return fourOhFour;
        
        logger.debug('SPA mode enabled, returning default file');
        [err, cacheObject] = await w(getAndCache(PREFIX + '/' + DEFAULT_FILE_PATH, bustCache));

        if (err) {
            logger.error('Failed to find the default file');
            return fourOhFour;
        }
    }

    const {file, body} = cacheObject;
    logger.debug(file);

    // Return the response with the default headers merged and overwritten by the content headers
    return mapS3Object(body, {
        ...DEFAULT_RESPONSE_HEADERS,
        ...{
            // No idea why, but s3 return the content type of the gz but the ui show's it as type gzip
            'Content-Type': file.ContentType, 
            // This tells the browser to unpack the gzip files
            'Content-Encoding': Key.endsWith('gz') ? 'gzip' : undefined, 
            // Set the cache
            'cache-control': getCacheHeader(file.ContentType)
        }
    }, 200, true)
}