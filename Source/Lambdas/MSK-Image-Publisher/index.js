const AWS = require('aws-sdk');
const { Kafka } = require('kafkajs');

exports.handler = async (event, context) =>{
    const kafka = new Kafka({
    clientId: 's3-msk-image-publisher',
    brokers: [
        process.env.MSK_BROKER_LIST.split(',')
    ],
    ssl: {
        rejectUnauthorized: true
    },
    sasl: {
        mechanism: 'AWS_MSK_IAM',
        authProvider: async () => {
            const credentials = new AWS.ChainableTemporaryCredentials({
                params: {
                    RoleArn: process.env.MSK_IMAGE_PUB_ROLE_ARN,
                    RoleSessionName: 'MSKImagePublisher'
                }
            });

            await credentials.getPromise();

            return {
                user: credentials.accessKeyId,
                pwd: credentials.secretAccessKey
            }
        }
    },
    });

    const producer = kafka.producer();
    await producer.connect();

    for (const record of event.Records) {
        const bucketName = record.s3.bucket.name;
        const key = record.s3.object.key;

        const s3 = new AWS.S3();
        const params = { Bucket: bucketName, Key: key };

        const data = await s3.getObject(params).promise();

        await producer.send({
            topic: process.env.MSK_TOPIC,
            messages: [
                { key: objectKey, value: data.Body.toString('base64') }
            ]
        });

        await producer.disconnect();

        return {
            statusCode: 200,
            body: JSON.stringify({
                message: "Successfully published image to MSK"
            })
        }
    }
}