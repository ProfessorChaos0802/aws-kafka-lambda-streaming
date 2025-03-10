resource "aws_security_group" "lambda_sg" {
  name_prefix = "lambda_sg"
  vpc_id      = var.vpc_id
  tags = {
    Name    = "Lambda Security Group"
    project = var.project
    owner   = var.owner
  }
}

resource "aws_security_group_rule" "lambda_sg_egress_to_msk" {
  type              = "egress"
  security_group_id = aws_security_group.lambda_sg.id
  cidr_blocks       = [var.vpc_cidr] # Ensures traffic goes to MSK SG
  description       = "Allow Lambda to connect to MSK brokers"
  from_port         = 9090
  to_port           = 9100
  protocol          = "tcp"
}

resource "aws_security_group_rule" "lambda_sg_egress_allows_sts_traffic" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.all_traffic]
  security_group_id = aws_security_group.lambda_sg.id
}

resource "aws_security_group_rule" "lambda_sg_ingress_from_msk" {
  type              = "ingress"
  security_group_id = aws_security_group.lambda_sg.id

  # Ensures traffic comes from MSK SG
  cidr_blocks = [
    var.subnet_a_cidr,
    var.subnet_b_cidr,
    var.subnet_c_cidr
  ]

  description = "Allow Lambda to connect to MSK brokers"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
}