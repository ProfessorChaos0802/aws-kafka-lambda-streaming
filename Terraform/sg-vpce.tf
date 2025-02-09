resource "aws_security_group" "vpce_sg" {
  name        = "vpce-sts-sg"
  description = "Security group for STS VPC Endpoint"
  vpc_id      = var.vpc_id

  # Allow inbound HTTPS traffic from the Lambda security group
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id] # Lambda SG
    description     = "Allow Lambda to connect to STS VPC endpoint"
  }

  tags = {
    Name = "vpce-sts-security-group"
  }
}

resource "aws_security_group_rule" "vpce_sg_egress_allow_outbound_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.all_traffic]
  security_group_id = aws_security_group.vpce_sg.id
}

resource "aws_security_group_rule" "vpce_sg_ingress_from_lambda" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.lambda_subnet_cidr]
  security_group_id = aws_security_group.lambda_sg.id
  description       = "Allow Lambda to connect to STS Endpoint"
}
