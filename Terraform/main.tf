terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.84"
    }
  }

  backend "s3" {
    bucket = var.tf_backend_bucket
    region = var.region
    key    = var.tf_backend_key
  }

}

provider "aws" {
  region = var.region
}