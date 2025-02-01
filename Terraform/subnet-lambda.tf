resource "aws_subnet" "aws_msk_streaming_lambda_subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.lambda_subnet_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "AWS MSK Streaming Lambda Subnet"
    project = var.project
    owner   = var.owner
  }
}