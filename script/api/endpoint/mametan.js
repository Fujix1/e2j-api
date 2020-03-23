/**
 * e2j mametan API
 */
import * as common from "../common";

// request URL
const jsonUrl = `${common.site_url}/mametan.json`;

exports.handler = async () => {
    try {
        let mametan = await common.getJsonHttp(jsonUrl);
        return {
            statusCode: 200,
            headers: common.jsonHeader,
            body: JSON.stringify(mametan)
        }
    } catch(error) {
        return {
            statusCode: 500,
            body: []
        }
    }
};
