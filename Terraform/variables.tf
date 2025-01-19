variable "region" {
  description = "AWS Region to build infrastructure in"
  type        = string
  default     = "us-east-2"
  nullable    = false
}

variable "tf_backend_bucket" {
  description = "AWS S3 bucket to store Terraform state"
  type        = string  
  nullable    = false
  default     = "aws-kafka-lambda-streaming-tfstate-048908104884"
}

variable "tf_backend_key" {
  description = "AWS S3 bucket key to store Terraform state"
  type        = string
  nullable    = false
  default     = "aws-kafka-lambda-streaming.tfstate"
}

variable "owner" {
  description = "Owner of the project"
  type        = string
  nullable    = false
  default     = "Charlie Hahm"
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
  nullable    = false
  default     = "1234567890"
}

variable "project" {
  description = "Name of the project"
  type        = string
  nullable    = false
  default     = "AWS MSK Streaming"
}

variable "tf_project_name" {
  description = "Name of the project"
  type        = string
  nullable    = false
  default     = "aws-msk-streaming"
}

variable "all_traffic" {
  description = "CIDR block for all traffic"
  type        = string
  default     = "0.0.0.0/0"
  nullable    = false
}

variable "vpc_cidr" {
  description = "CIDR block for professorchaos0802_vpc"
  type        = string
  nullable    = false
  default     = "194.75.0.0/16"
}

variable "vpc_id" {
  description = "ID for professorchaos0802_vpc"
  type        = string
  nullable    = false
  default     = "vpc-professorchaos0802"
}

variable "lambda_subnet_cidr" {
  description = "CIDR block for aws-msk-streaming public subnet 1"
  type        = string
  nullable    = false
  default     = "10.0.2.0/28"
}

variable "subnet_a_cidr" {
  description = "CIDR block for aws-msk-streaming subnet A"
  type        = string
  nullable    = false
  default     = "10.0.2.16/28"
}

variable "subnet_b_cidr" {
  description = "CIDR block for aws-msk-streaming subnet B"
  type        = string
  nullable    = false
  default     = "10.0.2.32/28"
}

variable "subnet_c_cidr" {
  description = "CIDR block for aws-msk-streaming subnet C"
  type        = string
  nullable    = false
  default     = "10.0.2.48/28"
}
