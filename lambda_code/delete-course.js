const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, DeleteCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const ddb = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
  try {
    const id = event.pathParameters?.id || event.id;
    await ddb.send(new DeleteCommand({ TableName: process.env.TABLE_NAME, Key: { id } }));
    return { statusCode: 200, body: JSON.stringify({ success: true, deleted: id }) };
  } catch (err) {
    return { statusCode: 500, body: JSON.stringify({ error: err.message }) };
  }
};