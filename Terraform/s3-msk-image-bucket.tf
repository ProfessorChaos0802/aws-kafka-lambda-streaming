resource "aws_s3_bucket" "msk_image_bucket" {
  bucket = "msk-image-bucket-${var.account_id}"

  # Force deletion on terraform destory
  force_destroy = true

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_s3_bucket_notification" "msk_image_bucket_notification_node" {
  bucket = aws_s3_bucket.msk_image_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_image_publisher_node.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".jpg" # Only trigger on image uploads
  }
}

resource "aws_s3_bucket_notification" "msk_image_bucket_notification_python" {
  bucket = aws_s3_bucket.msk_image_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_image_publisher_python.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".jpg" # Only trigger on image uploads
  }
}