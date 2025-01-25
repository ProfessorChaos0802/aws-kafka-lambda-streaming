const { fromNodeProviderChain } = require('@aws-sdk/credential-providers');
const { Kafka } = require('kafkajs');
const AWS = require('aws-sdk');

exports.handler = async (event, context) =>{
    const region = process.env.AWS_REGION;

    console.log(`MSK Broker List: ${process.env.MSK_BROKER_LIST}`);
    const kafka = new Kafka({
    clientId: 's3-msk-image-publisher',
    brokers: process.env.MSK_BROKER_LIST.split(','),
    ssl: true,
    sasl: {
        mechanism: 'aws',
        authenticationProvider: async () => {
            const credentials = new AWS.ChainableTemporaryCredentials({
              params: {
                RoleArn: process.env.MSK_IMAGE_PUB_ROLE_ARN,
                RoleSessionName: 'MSKImagePublisher',
              },
            });
  
            // Wait for credentials to resolve
            await credentials.getPromise();
  
            return {
              user: credentials.accessKeyId,
              password: credentials.secretAccessKey, // Correctly assign the property
              sessionToken: credentials.sessionToken, // Include sessionToken for temporary credentials
            };
          },
    },
    connectionTimeout: 10000,
    requestTimeout: 10000
    });

    // const credentials = fromNodeProviderChain({ region });
    // kafka.sasl.password = async () => {
    //     const { accessKeyId, secretAccessKey, sessionToken } = await credentials();

    //     return `AWS_ACCESS_KEY_ID=${accessKeyId},AWS_SECRET_ACCESS_KEY=${secretAccessKey},AWS_SESSION_TOKEN=${sessionToken}`;
    // };

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