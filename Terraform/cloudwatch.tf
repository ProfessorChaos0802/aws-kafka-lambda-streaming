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

resource "aws_cloudwatch_log_group" "s3_msk_lambda_group" {
  name              = "/aws/lambda/${aws_lambda_function.s3_msk_image_publisher.function_name}"
  retention_in_days = 3

  # Allow group deletion during terraform destroy
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name    = "AWS MSK Lambda Streaming S3 MSK Log Group"
    project = var.project
    owner   = var.owner
  }
}