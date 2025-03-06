resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          "AWS" : "arn:aws:iam::${var.account_id}:role/${aws_iam_role.lambda_execution_role.name}" # Adding trust policy for the given IAM role
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

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}


