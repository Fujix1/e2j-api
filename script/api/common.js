/**
 * common.js
 */
import axios from 'axios';

/**
 * Netlify environment variables
 *
 * @see https://docs.netlify.com/configure-builds/environment-variables/#deploy-urls-and-metadata
 */
export const site_url = process.env['URL'];

export const jsonHeader = {
    "Content-Type": "application/json; charset=utf-8"
};

/**
 * response cache on AWS Lambda
 */
let jsonCache = {};

/**
 * async http request
 *
 * @param url
 * @return JSON
 */
export async function getJson(url) {
    if(url in jsonCache) return jsonCache[url];
    try {
        const res = await axios.get(url);
        jsonCache[url] = res.data;
        return jsonCache[url];
    } catch (error) {
        console.log(error);
        throw Error(error);
    }
}
