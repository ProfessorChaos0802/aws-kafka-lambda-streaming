data "archive_file" "s3_image_publisher_python" {
  type        = "zip"
  source_dir  = "../Source/Lambdas/MSK-Image-Publisher-Python"
  output_path = "../Source/Lambdas/msk-image-publisher-python.zip"
}

resource "aws_lambda_function" "s3_image_publisher_python" {
  function_name    = "s3_image_publisher_python"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "imagePublisher.lambda_handler"
  timeout          = 150
  memory_size      = 128
  filename         = data.archive_file.s3_image_publisher_python.output_path
  source_code_hash = data.archive_file.s3_image_publisher_python.output_base64sha256

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
      AUTH_REGION            = var.region
      MSK_TOPIC              = "${aws_s3_bucket.msk_image_bucket.id}-s3-image-streaming-python"
      MSK_BROKER_LIST        = aws_msk_cluster.msk_lambda_streaming_cluster.bootstrap_brokers_sasl_iam
      MSK_IMAGE_PUB_ROLE_ARN = aws_iam_role.s3_publish_msk_role.arn
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

# A single event can only notify a single Lambda function. Uncomment here and comment out in node lambda to enable

# Lambda Permission for S3 to Invoke
resource "aws_lambda_permission" "allow_s3_invoke_python" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_image_publisher_python.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.msk_image_bucket.arn
}