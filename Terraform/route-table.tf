resource "aws_route_table" "msk_lambda_streaming_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.all_traffic
    vpc_endpoint_id = aws_vpc_endpoint.sts.id
  }

  tags = {
    Name    = "AWS MSK Lambda Streaming Route Table"
    project = var.project
    owner   = var.owner
  }
}