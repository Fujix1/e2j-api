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
