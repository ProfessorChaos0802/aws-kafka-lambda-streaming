import os
import boto3
import base64
import json
from kafka import KafkaProducer

def get_iam_auth_token():
    """Generates an IAM authentication token for MSK."""
    role_arn = os.getenv("MSK_IMAGE_PUB_ROLE_ARN")
    region = os.getenv("AUTH_REGION")

    sts_client = boto3.client('sts', region_name=region, endpoint_url=f"https://sts.{region}.amazonaws.com")

    token = sts_client.assume_role(RoleArn=role_arn, RoleSessionName="MSKSession")

    credentials = token['Credentials']
    return credentials['SessionToken'], credentials['AccessKeyId'], credentials['SecretAccessKey']

def lambda_handler(event, context):
    """AWS Lambda handler function."""
    # Extract IAM credentials for Kafka authentication
    session_token, access_key_id, secret_access_key = get_iam_auth_token()

    # Fetch Kafka broker list and topic
    kafka_brokers = os.getenv("MSK_BROKER_LIST").split(",")
    topic = os.getenv("MSK_TOPIC")

    # Kafka Producer Configuration
    conf = {
        'bootstrap_servers': kafka_brokers,
        'security_protocol': 'SASL_SSL',
        'sasl_mechanism': 'AWS_MSK_IAM',
        'sasl_iam_access_key_id': access_key_id,
        'sasl_iam_secret_access_key': secret_access_key,
        'sasl_iam_session_token': session_token
    }

    producer = KafkaProducer(**conf)

    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        object_key = record['s3']['object']['key']

        # Fetch file data from S3
        s3_client = boto3.client('s3')
        response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
        file_data = response['Body'].read()

        # Encode file data in Base64
        encoded_data = base64.b64encode(file_data).decode('utf-8')

        # Send message to Kafka
        producer.send(topic, key=object_key.encode('utf-8'), value=encoded_data.encode('utf-8'))
        producer.flush()

        print(f"Published {object_key} to {topic}")

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Successfully published image to MSK"})
    }
