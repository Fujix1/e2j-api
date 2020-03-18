/**
 * common.js
 */
import * as request from 'request';

/**
 * Netlify environment variables
 *
 * @see https://docs.netlify.com/configure-builds/environment-variables/#deploy-urls-and-metadata
 */
export const site_url = process.env['URL'];

/**
 * response cache on AWS Lambda
 */
let requestCache = {};

/**
 * http request
 *
 * @param url
 */
export const requestRawJSON = function(url, callback) {
    if(url in requestCache) {
        callback(null, {
            statusCode: 200,
            headers: {
                "Content-Type": "application/json",
                "X-E2J-Cache": "lambda"
            },
            body: requestCache[url]
        });
    } else {
        request({ url: url, method: "GET"}, function (error, response, body) {
            if (error) {
                callback(null, {
                    statusCode: 500
                });
            } else {
                requestCache[url] = body;
                callback(null, {
                    statusCode: 200,
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: body
                });
            }
        });
    }
}
