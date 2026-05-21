const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, ScanCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const ddb = DynamoDBDocumentClient.from(client);

exports.handler = async () => {
  try {
    const data = await ddb.send(new ScanCommand({ TableName: process.env.TABLE_NAME }));
    return { statusCode: 200, body: JSON.stringify(data.Items) };
  } catch (err) {
    return { statusCode: 500, body: JSON.stringify({ error: err.message }) };
  }
};