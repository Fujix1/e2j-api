/**
 * HOW DENGEROUSE API
 */
import * as common from "../common";

exports.handler = (event, context, callback) => {
    let env = process.env;
    callback(null, {
        statusCode: 200,
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(env)
    });
};
