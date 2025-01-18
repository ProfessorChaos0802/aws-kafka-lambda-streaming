resource "aws_cloudwatch_log_group" "msk_cloudwatch_group" {
  name              = "msk-cloudwatch-group"
  retention_in_days = 3
  tags = {
    Name    = "AWS MSK Lambda Streaming MSK Log Group"
    project = var.project
    owner   = var.owner
  }
}