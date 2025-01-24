resource "aws_cloudwatch_log_group" "msk_cloudwatch_group" {
  name              = "msk-cloudwatch-group"
  retention_in_days = 3

  # Allow group deletion during terraform destroy
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name    = "AWS MSK Lambda Streaming MSK Log Group"
    project = var.project
    owner   = var.owner
  }
}