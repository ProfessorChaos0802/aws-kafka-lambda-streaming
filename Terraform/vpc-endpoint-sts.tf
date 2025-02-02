resource "aws_vpc_endpoint" "sts" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.sts"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.aws_msk_streaming_lambda_subnet.id
  ]
  security_group_ids = [
    aws_security_group.lambda_sg.id
  ]

  tags = {
    project = var.project
    owner   = var.owner
  }
}
