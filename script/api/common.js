/**
 * common.js
 */
import crypto from 'crypto'
import axios from 'axios';
import fs from 'fs';
import decompress from 'decompress';
import decompressTarGz from 'decompress-targz';

/**
 * for Promise
 */
const fsp = fs.promises;

/**
 * Netlify environment variables
 *
 * @see https://docs.netlify.com/configure-builds/environment-variables/#deploy-urls-and-metadata
 */
export const site_url = process.env['URL'];

export const jsonHeader = {
    "Content-Type": "application/json; charset=utf-8",
    "Access-Control-Allow-Origin":  "*"
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
export async function getJsonHttp(url) {
    if(url in jsonCache) return jsonCache[url];
    try {
        if(url.match(/^.+\.tar\.gz$/)) {
            // for .tar.gz arcive
            console.log("@http start" + url);
            const res = await axios.get(url, { responseType: "arraybuffer" });
            const filename = crypto.createHash('sha1').update(url).digest('hex');
            const tar = "/tmp/" + filename + ".tar.gz";
            console.log("@http end");
            console.log("@write file start");
            await fsp.writeFile(tar, res.data);
            console.log("@write file end");
            console.log("@decomporess start");
            let ret = await decompress(tar, null, { plugins: [ decompressTarGz() ] });
            console.log("@decomporess end");
            console.log("@json parse start");
            let whatsnewjson = JSON.parse(ret[0].data.toString('utf-8'));
            console.log("@json parse end");
            console.log("@file remove start");
            await fsp.unlink(tar);
            console.log("@file remove end");
            jsonCache[url] = whatsnewjson;
        } else {
            // for plane json
            const res = await axios.get(url);
            jsonCache[url] = res.data;
        }
        return jsonCache[url];
    } catch (error) {
        console.log(error);
        throw Error(error);
    }
}
