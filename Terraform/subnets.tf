resource "aws_subnet" "aws_msk_streaming_lambda_subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.lambda_subnet_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "AWS MSK Streaming Public1 Subnet"
    project = var.project
    owner   = var.owner
  }
}

resource "aws_subnet" "aws_msk_streaming_east2a" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_a_cidr
  availability_zone = "${var.region}a"
  tags = {
    Name    = "AWS MSK Streaming Subnet East 2A"
    project = var.project
    owner   = var.owner
  }
}

resource "aws_subnet" "aws_msk_streaming_east2b" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_b_cidr
  availability_zone = "${var.region}b"
  tags = {
    Name    = "AWS MSK Streaming Subnet East 2B"
    project = var.project
    owner   = var.owner
  }
}

resource "aws_subnet" "aws_msk_streaming_east2c" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_c_cidr
  availability_zone = "${var.region}c"
  tags = {
    Name    = "AWS MSK Streaming Subnet East 2C"
    project = var.project
    owner   = var.owner
  }
}