resource "aws_route" "sts_route" {
  route_table_id         = aws_route_table.msk_lambda_streaming_route_table.id
  destination_cidr_block = var.vpc_cidr
  vpc_endpoint_id        = aws_vpc_endpoint.sts_endpoint.id
}