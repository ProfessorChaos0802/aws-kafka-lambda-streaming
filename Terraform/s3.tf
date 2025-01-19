resource "aws_s3_bucket" "msk_logs_bucket" {
  bucket = "msk-logs-bucket-${var.account_id}"

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_s3_bucket_policy" "msk_logging_policy" {
  bucket = aws_s3_bucket.msk_logs_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowMSKLogging",
        Effect = "Allow",
        Principal = {
          Service = "kafka.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.msk_logs_bucket.arn}/*",
        Condition = {
          StringEquals = {
            "aws:SourceAccount" : var.account_id
          },
          ArnLike = {
            "aws:SourceArn" : "arn:aws:kafka:${var.region}:${var.account_id}:*"
          }
        }
      }
    ]
  })
}
