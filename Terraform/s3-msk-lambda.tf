data "archive_file" "s3_msk_image_publisher" {
  type        = "zip"
  source_dir  = "../Source/Lambdas/MSK-Image-Publisher"
  output_path = "../Source/Lambdas/msk-image-publisher.zip"
}

resource "aws_lambda_function" "s3_msk_image_publisher" {
  function_name    = "s3_msk_image_publisher"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.s3_msk_image_publisher_role.arn
  handler          = "index.handler"
  timeout          = 30
  memory_size      = 128
  filename         = data.archive_file.s3_msk_image_publisher.output_path
  source_code_hash = data.archive_file.s3_msk_image_publisher.output_base64sha256

  # VPC Configuration
  vpc_config {
    subnet_ids = [
      aws_subnet.aws_msk_streaming_lambda_subnet.id
    ]

    security_group_ids = [
      aws_security_group.msk_sg.id
    ]
  }

  # Environment Variables
  environment {
    variables = {
      LOG_GROUP_NAME         = aws_cloudwatch_log_group.s3_msk_lambda_group.name
      MSK_TOPIC              = "${aws_s3_bucket.msk_image_bucket.id}-s3-image-streaming"
      MSK_BROKER_LIST        = aws_msk_cluster.msk_lambda_streaming_cluster.bootstrap_brokers_sasl_iam
      MSK_IMAGE_PUB_ROLE_ARN = aws_iam_role.s3_msk_image_publisher_role.arn
    }
  }

  tags = {
    project = var.project
    owner   = var.owner
  }

  depends_on = [
    aws_msk_cluster.msk_lambda_streaming_cluster
  ]
}

# Lambda Permission for S3 to Invoke
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_msk_image_publisher.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.msk_image_bucket.arn
}

output "broker_list" {
  value = aws_msk_cluster.msk_lambda_streaming_cluster.bootstrap_brokers_sasl_iam
}