resource "aws_iam_policy" "lambda_vpc_endpoint_policy" {
  name        = "lambda_vpc_endpoint_policy"
  description = "Lambda VPC Endpoint Policy allowing Lambda to access VPC Endpoints"
  policy      = data.aws_iam_policy_document.lambda_vpc_endpoint_policy_document.json
}

#--------------------Policy Documents---------------------

data "aws_iam_policy_document" "lambda_vpc_endpoint_policy_document" {
  # VPC Permissions - VPC Endpoints
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeVpcEndpoints"
    ]
    resources = ["*"]
  }

  # Cloudwatch Permissions
  statement {
    actions   = ["logs:*"]
    resources = ["*"]
  }
}