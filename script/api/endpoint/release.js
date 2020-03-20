/**
 * e2j release API
 */
import * as common from "../common";

// request URL
const url = `${common.site_url}/releases.json`;

exports.handler = async () => {
    try {
        let release = await common.getJsonHttp(url);
        return {
            statusCode: 200,
            headers: common.jsonHeader,
            body: JSON.stringify(release)
        }
    } catch(error) {
        return {
            statusCode: 500,
            body: []
        }
    }
};
