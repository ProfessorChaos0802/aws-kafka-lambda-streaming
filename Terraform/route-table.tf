resource "aws_route_table" "msk_lambda_streaming_route_table" {
  vpc_id = var.vpc_id
}