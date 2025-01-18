resource "aws_s3_bucket" "msk_logs_bucket" {
  bucket = "msk-logs-bucket"

  tags = {
    project = var.project
    owner   = var.owner
  }
}

resource "aws_s3_bucket_policy" "msk_logging_policy" {
  bucket = aws_s3_bucket.msk_logging_bucket.id

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

resource "aws_s3_bucket_acl" "msk_logs_bucket_acl" {
  bucket = aws_s3_bucket.msk_logs_bucket.id
  acl    = "private"
}