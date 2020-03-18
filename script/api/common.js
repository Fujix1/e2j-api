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
 * http request
 *
 * @param url
 */
export const requestRawJSON = function(url, callback) {
    request({ url: url, method: "GET"}, function (error, response, body) {
        if (error) {
            callback(null, {
                statusCode: 500
            });
        } else {
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
