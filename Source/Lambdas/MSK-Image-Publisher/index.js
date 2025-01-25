const { fromNodeProviderChain } = require('@aws-sdk/credential-providers');
const { Kafka } = require('kafkajs');

exports.handler = async (event, context) =>{
    const region = process.env.AWS_REGION;

    console.log(`MSK Broker List: ${process.env.MSK_BROKER_LIST}`);
    const kafka = new Kafka({
    clientId: 's3-msk-image-publisher',
    brokers: process.env.MSK_BROKER_LIST.split(','),
    ssl: true,
    sasl: {
        mechanism: 'aws',
        authorizationIdentidy: '',
        username: '',
        password: ''
    },
    connectionTimeout: 10000,
    requestTimeout: 10000
    });

    console.log(kafka.brokers);

    const credentials = fromNodeProviderChain({ region });
    kafka.sasl.password = async () => {
        const { accessKeyId, secretAccessKey, sessionToken } = await credentials();

        return `AWS_ACCESS_KEY_ID=${accessKeyId},AWS_SECRET_ACCESS_KEY=${secretAccessKey},AWS_SESSION_TOKEN=${sessionToken}`;
    };

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