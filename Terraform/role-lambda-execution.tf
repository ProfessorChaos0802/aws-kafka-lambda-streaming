resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = [
            "lambda.amazonaws.com" # Allow Lambda to assume the role
          ]
        }
      }
    ]
  })
}

#--------------------Role Policy Attachments---------------------

resource "aws_iam_role_policy_attachment" "lambda_vpc_endpoint_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_vpc_endpoint_policy.arn
}



