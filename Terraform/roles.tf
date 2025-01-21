resource "aws_iam_role" "s3_msk_image_publisher_role" {
  name = "s3_msk_image_publisher_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_msk_image_publisher_execution_policy" {
  role       = aws_iam_role.s3_msk_image_publisher_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_msk_image_publisher_s3_access_policy" {
  role       = aws_iam_role.s3_msk_image_publisher_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy" "lambda_msk_publisher_policy" {
  role = aws_iam_role.s3_msk_image_publisher_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kafka:DescribeCluster",
          "kafka:ListTopics",
          "kafka:WriteData",
          "kafka:DescribeTopic"
        ],
        Resource = aws_msk_cluster.msk_lambda_streaming_cluster.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_vpc_policy" {
  role = aws_iam_role.s3_msk_image_publisher_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
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