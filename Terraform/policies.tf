resource "aws_msk_cluster_policy" "example" {
  cluster_arn = aws_msk_cluster.msk_lambda_streaming_cluster.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "msk-lambda-streaming-cluster-policy"
      Effect = "Allow"
      Principal = {
        "AWS" = aws_iam_role.s3_msk_image_publisher_role.arn
      }
      Action = [
        "kafka:Describe*",
        "kafka:Get*",
        "kafka:CreateVpcConnection",
        "kafka:GetBootstrapBrokers",
      ]
      Resource = aws_msk_cluster.msk_lambda_streaming_cluster.arn
    }]
  })
}