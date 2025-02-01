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
  from_port         = 9098
  to_port           = 9098
  protocol          = "tcp"
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