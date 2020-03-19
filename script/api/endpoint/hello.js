import fs from 'fs';

const mametan = fs.readFileSync('generator/static/mametan.json', 'utf-8');

exports.handler = async () => {
    return {
        statusCode: 200,
        headers: {
            "Content-Type": "application/json"
        },
        body: mametan
    }
};
