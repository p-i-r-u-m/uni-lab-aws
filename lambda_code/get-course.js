const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const ddb = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
  try {
    // Беремо ID з параметрів запиту (для майбутнього API Gateway)
    const id = event.pathParameters?.id || event.id;
    const data = await ddb.send(new GetCommand({ TableName: process.env.TABLE_NAME, Key: { id } }));
    
    if (!data.Item) return { statusCode: 404, body: JSON.stringify({ error: "Not found" }) };
    return { statusCode: 200, body: JSON.stringify(data.Item) };
  } catch (err) {
    return { statusCode: 500, body: JSON.stringify({ error: err.message }) };
  }
};