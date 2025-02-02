import os
import boto3
import base64
import json
import logging
from kafka import KafkaProducer

# Initialize logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_iam_auth_token():
    """Generates an IAM authentication token for MSK with enhanced error handling and logging."""
    try:
        role_arn = os.getenv("MSK_IMAGE_PUB_ROLE_ARN")
        region = os.getenv("AUTH_REGION")

        logger.info(f"Attempting to get IAM token for role: {role_arn} in region: {region}")

        # Set the endpoint URL for sts based on the region
        sts_endpoint = f"https://sts.{region}.amazonaws.com"
        logger.info(f"Using STS endpoint: {sts_endpoint}")

        sts_client = boto3.client('sts', region_name=region, endpoint_url=sts_endpoint)

        # Request temporary credentials
        token = sts_client.assume_role(RoleArn=role_arn, RoleSessionName="MSKSession")

        # Extract the credentials from the response
        credentials = token['Credentials']
        logger.info("Successfully retrieved IAM credentials")

        return credentials['SessionToken'], credentials['AccessKeyId'], credentials['SecretAccessKey']

    except Exception as e:
        logger.error(f"Error retrieving IAM credentials: {str(e)}")
        raise

def lambda_handler(event, context):
    """AWS Lambda handler function with enhanced error handling."""
    try:
        # Retrieve IAM credentials for Kafka authentication
        session_token, access_key_id, secret_access_key = get_iam_auth_token()

        # Fetch MSK broker list and topic from environment variables
        kafka_brokers = os.getenv("MSK_BROKER_LIST").split(",")
        topic = os.getenv("MSK_TOPIC")

        logger.info(f"Kafka brokers: {kafka_brokers}")
        logger.info(f"Target Kafka topic: {topic}")

        # Kafka Producer Configuration
        conf = {
            'bootstrap_servers': kafka_brokers,
            'security_protocol': 'SASL_SSL',
            'sasl_mechanism': 'AWS_MSK_IAM',
            'sasl_iam_access_key_id': access_key_id,
            'sasl_iam_secret_access_key': secret_access_key,
            'sasl_iam_session_token': session_token
        }

        # Create Kafka producer
        producer = KafkaProducer(**conf)

        # Process S3 event records
        for record in event['Records']:
            bucket_name = record['s3']['bucket']['name']
            object_key = record['s3']['object']['key']

            # Fetch file data from S3
            s3_client = boto3.client('s3')
            response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
            file_data = response['Body'].read()

            # Encode the file data in Base64
            encoded_data = base64.b64encode(file_data).decode('utf-8')

            # Send the encoded file data to Kafka
            producer.send(topic, key=object_key.encode('utf-8'), value=encoded_data.encode('utf-8'))
            producer.flush()

            logger.info(f"Published {object_key} to Kafka topic {topic}")

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Successfully published image to MSK"})
        }

    except Exception as e:
        logger.error(f"Error in Lambda handler: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"message": f"Error: {str(e)}"})
        }
