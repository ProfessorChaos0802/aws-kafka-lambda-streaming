resource "aws_iam_role" "s3_image_msk_publisher_role" {
  name = "s3_image_msk_publisher_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = [
            "lambda.amazonaws.com", # Allow Lambda to assume the role
            "kafka.amazonaws.com"   # Allow MSK service to interact with the role (if needed)
          ]
        }
      }
    ]
  })

  # Lambda MSK Publisher Policy
  inline_policy {
    name = "lambda-msk-publisher-policy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        # Lambda basic execution role
        {
          Effect = "Allow",
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          Resource = "arn:aws:logs:*:*:*"
        },
        # S3 read-only access
        {
          Effect   = "Allow",
          Action   = "s3:GetObject",
          Resource = "arn:aws:s3:::*/*"
        },
        # MSK (Kafka) specific access
        {
          Effect = "Allow",
          Action = [
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
          ],
          Resource = aws_msk_cluster.msk_lambda_streaming_cluster.arn
        },

        # Allow assume role (for the Lambda to get MSK authentication token)
        {
          Effect   = "Allow",
          Action   = "sts:AssumeRole",
          Resource = "arn:aws:iam::${var.account_id}:role/s3_image_msk_publisher_role"
        }
      ]
    })
  }

  # Labda Execution Policy
  inline_policy {
    name   = "lambda_basic_execution_policy"
    policy = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  }

  # S3 Read Only Policy
  inline_policy {
    name   = "s3_read_only_access_policy"
    policy = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }

  # VPC Policy
  inline_policy {
    name = "lambda-vpc-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface"
          ]
          Resource = "*"
        },
        {
          Effect   = "Allow"
          Action   = "logs:*"
          Resource = "*"
        }
      ]
    })
  }
}

