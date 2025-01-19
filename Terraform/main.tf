terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.84"
    }
  }

  backend "s3" {
    bucket = "aws-kafka-lambda-streaming-tfstate-048908104884"
    region = "us-east-2"
    key    = "aws-kafka-lambda-streaming.tfstate"
  }

}

provider "aws" {
  profile = "default"
  region  = var.region
}