resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "lambda_execution_policy"
  description = "Policy allowing lambda_execution role to assume s3_msk_publish role"
  policy      = data.aws_iam_policy_document.lambda_execution_policy_document.json
}

#--------------------Policy Documents--------------------

data "aws_iam_policy_document" "lambda_execution_policy_document" {
  # Allow assume role (for the Lambda to get MSK authentication token)
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::${var.account_id}:role/${aws_iam_role.s3_publish_msk_role.name}"
    ]
  }
}