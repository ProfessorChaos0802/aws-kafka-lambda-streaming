variable "owner" {
  description = "Owner of the project"
  type        = string
  nullable    = false
  default     = "Charlie Hahm"
}

variable "region" {
  description = "AWS Region to build infrastructure in"
  type        = string
  default     = "us-east-2"
  nullable    = false
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
  default     = "AWS MKS Streaming"
}

variable "tf_project_name" {
  description = "Name of the project"
  type        = string
  nullable    = false
  default     = "aws-kafka-lambda-streaming"
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