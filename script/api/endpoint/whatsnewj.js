/**
 * e2j whatsnewj API
 */
import * as common from "../common";
import whatsnewj from "../json/whatsnewj.json";

// JSON URL
// const jsonUrl = `${common.site_url}/whatsnewj.tar.bz2`;

exports.handler = async (event) => {
    try {
        // let whatsnewj = await common.getJsonHttp(jsonUrl);
        let answer = [];
        let query = event.queryStringParameters.q;
        console.log("queryStringParameters" + event.queryStringParameters);
        if(query && whatsnewj[query]) {
            answer = whatsnewj[query];
        }
        return {
            statusCode: 200,
            headers: common.jsonHeader,
            body: JSON.stringify(answer)
        }
    } catch(error) {
        return {
            statusCode: 500,
            body: []
        }
    }
};
