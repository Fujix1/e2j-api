/**
 * e2j releases API
 */
import * as common from "../common";

exports.handler = (event, context, callback) => {
    common.requestRawJSON(common.site_url + "/mametan.json", callback);
};
