resource "aws_security_group" "msk_sg" {
  name_prefix = "msk_sg"
  vpc_id      = var.vpc_id
  tags = {
    Name    = "AWS MSK Lambd Streaming MSK Security Group"
    project = var.project
    owner   = var.owner
  }
}

resource "aws_security_group_rule" "msk_sg_egress" {
  type              = "egress"
  security_group_id = aws_security_group.msk_sg.id
  cidr_blocks       = [var.all_traffic]
  description       = "AWS MSK Lambda Streaming MSK Egress Rule"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
}

resource "aws_security_group_rule" "msk_sg_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.msk_sg.id
  cidr_blocks       = [var.aws_msk_streaming_lambda_subnet.cidr_block]
  description       = "AWS MSK Lambda Streaming MSK Ingress Rule"
  from_port         = 9094
  to_port           = 9094
  protocol          = "tcp"
}