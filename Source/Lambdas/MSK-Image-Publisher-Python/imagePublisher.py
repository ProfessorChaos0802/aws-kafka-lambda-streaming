import os
import boto3
import json
import base64
from kafka import KafkaProducer

def get_iam_auth_token():
    """Generates an IAM authentication token for MSK."""
    region = os.getenv("AUTH_REGION")
    role_arn = os.getenv("MSK_IMAGE_PUB_ROLE_ARN")

    # Initialize a boto3 client for STS
    sts_client = boto3.client('sts', region_name=region)

    # Generate a temporary IAM auth token
    token = sts_client.assume_role(
        RoleArn=role_arn,
        RoleSessionName="MSKImagePublisherSession"
    )

    # The token from assume_role is in the credentials
    credentials = token['Credentials']
    return credentials['SessionToken'], credentials['AccessKeyId'], credentials['SecretAccessKey']

def kafka_delivery_report(err, msg):
    """Reports success or failure of Kafka message delivery."""
    if err is not None:
        print(f"Message delivery failed: {err}")
    else:
        print(f"Message delivered to {msg.topic()} [{msg.partition()}]")

def lambda_handler(event, context):
    """AWS Lambda handler function."""
    # Extract S3 event information
    s3_client = boto3.client('s3')

    # Fetch IAM token credentials using the defined method
    session_token, access_key_id, secret_access_key = get_iam_auth_token()

    # Extract MSK brokers and topic from environment variables
    kafka_brokers = os.getenv("MSK_BROKER_LIST").split(",")
    topic = os.getenv("MSK_TOPIC")

    # Kafka Producer Configuration
    conf = {
        'bootstrap_servers': ','.join(kafka_brokers),
        'security_protocol': 'SASL_SSL',
        'sasl_mechanism': 'OAUTHBEARER',
        'sasl_oauthbearer_token': session_token,
        'sasl_oauthbearer_client_id': access_key_id,
        'sasl_oauthbearer_client_secret': secret_access_key,
    }

    # Create Kafka Producer
    producer = KafkaProducer(**conf)

    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        object_key = record['s3']['object']['key']

        # Download the file from S3
        response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
        file_data = response['Body'].read()

        # Encode the file data in Base64
        encoded_data = base64.b64encode(file_data).decode('utf-8')

        # Send message to Kafka topic
        producer.send(topic, key=object_key.encode('utf-8'), value=encoded_data.encode('utf-8'), callback=kafka_delivery_report)
        producer.flush()

        print(f"Successfully published image {object_key} to Kafka topic {topic}")

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Successfully published image to MSK"})
    }
