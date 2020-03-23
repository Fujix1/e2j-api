/**
 * e2j release API
 */
import * as common from "../common";
import release from "../json/releases.json";

// request URL
// const jsonUrl = `${common.site_url}/releases.json`;

exports.handler = async () => {
    try {
        // let release = await common.getJsonHttp(jsonUrl);
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
