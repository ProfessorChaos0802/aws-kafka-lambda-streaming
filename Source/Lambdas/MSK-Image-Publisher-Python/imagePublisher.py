import os
import boto3
import json
import base64
import time
from kafka import KafkaProducer

# Global cache for IAM auth credentials
IAM_CREDENTIALS_CACHE = {}

def get_iam_auth_token():
    """Generates and caches an IAM authentication token for MSK."""
    global IAM_CREDENTIALS_CACHE

    if IAM_CREDENTIALS_CACHE and time.time() < IAM_CREDENTIALS_CACHE["expiration"]:
        print("Using cached IAM credentials")
        return IAM_CREDENTIALS_CACHE["session_token"], IAM_CREDENTIALS_CACHE["access_key_id"], IAM_CREDENTIALS_CACHE["secret_access_key"]

    print("Fetching new IAM credentials")
    region = os.getenv("AUTH_REGION")
    role_arn = os.getenv("MSK_IMAGE_PUB_ROLE_ARN")

    sts_client = boto3.client('sts', region_name=region)

    token = sts_client.assume_role(
        RoleArn=role_arn,
        RoleSessionName="MSKImagePublisherSession"
    )

    credentials = token['Credentials']
    IAM_CREDENTIALS_CACHE = {
        "session_token": credentials['SessionToken'],
        "access_key_id": credentials['AccessKeyId'],
        "secret_access_key": credentials['SecretAccessKey'],
        "expiration": credentials['Expiration'].timestamp() - 60  # Cache with buffer
    }

    return credentials['SessionToken'], credentials['AccessKeyId'], credentials['SecretAccessKey']

def kafka_delivery_report(err, msg):
    """Reports success or failure of Kafka message delivery."""
    if err is not None:
        print(f"Kafka delivery failed: {err}")
    else:
        print(f"Kafka message delivered to {msg.topic()} [{msg.partition()}]")

def lambda_handler(event, context):
    """AWS Lambda handler function."""
    try:
        print("Lambda invoked. Event:", json.dumps(event))
        
        # Extract S3 event information
        s3_client = boto3.client('s3')

        # Fetch IAM token credentials (cached)
        session_token, access_key_id, secret_access_key = get_iam_auth_token()

        # Extract MSK brokers and topic from environment variables
        kafka_brokers = os.getenv("MSK_BROKER_LIST").split(",")
        topic = os.getenv("MSK_TOPIC")

        # Kafka Producer Configuration
        conf = {
            'bootstrap_servers': kafka_brokers,
            'security_protocol': 'SASL_SSL',
            'sasl_mechanism': 'OAUTHBEARER',
            'sasl_oauthbearer_token': session_token,
            'sasl_oauthbearer_client_id': access_key_id,
            'sasl_oauthbearer_client_secret': secret_access_key,
        }

        print("Initializing Kafka Producer")
        producer = KafkaProducer(**conf)

        for record in event.get("Records", []):
            bucket_name = record["s3"]["bucket"]["name"]
            object_key = record["s3"]["object"]["key"]

            print(f"Processing file: {object_key} from bucket: {bucket_name}")

            # Download the file from S3
            response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
            file_data = response["Body"].read()

            # Encode the file data in Base64
            encoded_data = base64.b64encode(file_data).decode("utf-8")

            # Send message to Kafka topic
            producer.send(topic, key=object_key.encode("utf-8"), value=encoded_data.encode("utf-8"), callback=kafka_delivery_report)
            producer.flush()

            print(f"Successfully published image {object_key} to Kafka topic {topic}")

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Successfully published image to MSK"})
        }

    except Exception as e:
        print(f"Lambda failed with error: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
