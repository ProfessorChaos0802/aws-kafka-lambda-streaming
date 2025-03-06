resource "aws_iam_policy" "s3_publish_msk_policy" {
  name        = "s3_publish_msk_policy"
  description = "Role allowing Read-Only access to S3 and MSK Publish permissions"
  policy      = data.aws_iam_policy_document.s3_publish_msk_policy_document.json
}

#--------------------Policy Documents--------------------

data "aws_iam_policy_document" "s3_publish_msk_policy_document" {
  # Cloudwatch Permissions
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  #   # S3 Permissions
  #   statement {
  #     actions = [
  #       "s3:GetObject"
  #     ]
  #     resources = ["arn:aws:s3:::*/*"]
  #   }

  # MSK Permissions
  statement {
    actions = [
      "kafka:CreateTopic",
      "kafka:Connect",
      "kafka:DescribeCluster",
      "kafka:DescribeClusterOperation",
      "kafka:GetBootstrapBrokers",
      "kafka:DescribeCluster",
      "kafka:ListTopics",
      "kafka:WriteData",
      "kafka:ReadData",
      "kafka:DescribeTopic"
    ]
    resources = [aws_msk_cluster.msk_lambda_streaming_cluster.arn]
  }

  # Allow assume role (for the Lambda to get MSK authentication token)
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::${var.account_id}:role/lambda_execution_role/*"
    ]
  }
}