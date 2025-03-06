resource "aws_iam_role" "s3_publish_msk_role" {
  name = "s3_publish_msk_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:role/${aws_iam_role.lambda_execution_role.name}",
          Service = [
            "lambda.amazonaws.com", # Allow Lambda to assume the role
            "kafka.amazonaws.com"   # Allow MSK service to interact with the role
          ]
        }
      }
    ]
  })
}

#--------------------Role Policy Attachments---------------------

resource "aws_iam_role_policy_attachment" "s3_read_only_policy_attachment" {
  role       = aws_iam_role.s3_publish_msk_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "s3_publish_msk_policy_attachment" {
  role       = aws_iam_role.s3_publish_msk_role.name
  policy_arn = aws_iam_policy.s3_publish_msk_policy.arn
}