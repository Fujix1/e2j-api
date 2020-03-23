/**
 * e2j whatsnewj API
 */
import * as common from "../common";

// JSON URL
const jsonUrl = `${common.site_url}/whatsnewj.tar.gz`;

exports.handler = async () => {
    try {
        let whatsnewj = await common.getJsonHttp(jsonUrl);
        return {
            statusCode: 200,
            headers: common.jsonHeader,
            body: JSON.stringify(whatsnewj)
        }
    } catch(error) {
        return {
            statusCode: 500,
            body: []
        }
    }
};
