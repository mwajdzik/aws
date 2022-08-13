const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB({region: 'us-west-2', apiVersion: '2012-08-10'});

module.exports.handler = (event, context, callback) => {
    const item = JSON.parse(event.Records[0].body);

    const params = {
        TableName: "ProductVisits",
        Item: {
            ProductVisitKey: {
                S: `${item.ProductId}`
            },
            ProductName: {
                S: `${item.ProductName}`
            },
            PricePerUnit: {
                S: `${item.PricePerUnit}`
            },
            CustomerId: {
                S: `${item.CustomerId}`
            },
            CustomerName: {
                S: `${item.CustomerName}`
            }
        },
    };

    dynamoDb.putItem(params, function (err, data) {
        if (err) {
            console.log("Error", err);
            callback(err);
        } else {
            callback(null, data);
        }
    });
}
