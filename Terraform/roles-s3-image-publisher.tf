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
}

#--------------------Policy Documents---------------------

data "aws_iam_policy_document" "lambda_msk_publisher_policy" {
  # Cloudwatch Permissions
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  # S3 Permissions
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = ["arn:aws:s3:::*/*"]
  }

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
      "arn:aws:iam::${var.account_id}:role/s3_image_msk_publisher_role",
      "arn:aws:iam::${var.account_id}:assumed-role/s3_image_msk_publisher_role/s3_image-publisher_python"
    ]
  }
}

data "aws_iam_policy_document" "lambda_vpc_policy" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeVpcEndpoints"
    ]
    resources = ["*"]
  }

  statement {
    actions   = ["logs:*"]
    resources = ["*"]
  }
}

#--------------------Role Policy Resources---------------------

resource "aws_iam_policy" "lambda_msk_publisher_policy" {
  name        = "lambda_msk_publisher_policy"
  description = "Lambda MSK Publisher Policy"
  policy      = data.aws_iam_policy_document.lambda_msk_publisher_policy.json
}

resource "aws_iam_policy" "lambda_vpc_policy" {
  name        = "lambda-vpc-policy"
  description = "Lambda VPC Policy"
  policy      = data.aws_iam_policy_document.lambda_vpc_policy.json
}

#--------------------Role Policy Attachments---------------------

resource "aws_iam_role_policy_attachment" "lambda_msk_execution_policy" {
  role       = aws_iam_role.s3_image_msk_publisher_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaMSKExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_read_only_access_policy" {
  role       = aws_iam_role.s3_image_msk_publisher_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_msk_publisher_policy" {
  role       = aws_iam_role.s3_image_msk_publisher_role.name
  policy_arn = aws_iam_policy.lambda_msk_publisher_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_policy" {
  role       = aws_iam_role.s3_image_msk_publisher_role.name
  policy_arn = aws_iam_policy.lambda_vpc_policy.arn
}



