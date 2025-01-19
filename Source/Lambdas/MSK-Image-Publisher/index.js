const AWS = require('aws-sdk');
const { Kafka } = require('kafkajs');

const s3 = new AWS.S3();
const kafka = new Kafka({
    clientId: 'msk-image-publisher',
    brokers: [
        process.env.KAFKA_BROKER
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

exports.handler = async (event) =>{

}