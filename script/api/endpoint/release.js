/**
 * e2j releases API
 */
import axios from 'axios';
import * as common from "../common";

exports.handler = async () => {
    const url = `${common.site_url}/releases.json`;
    return axios.get(url).then(({ data: data }) => ({
        statusCode: 200,
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(data)
    })).catch(e => ({
        statusCode: 400,
        body: e
    }));
};
