resource "aws_msk_cluster_policy" "msk_lambda_streaming_cluster_policy" {
  cluster_arn = aws_msk_cluster.msk_lambda_streaming_cluster.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "AllowIAMBasedAccess"
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
      Resource = "arn:aws:kafka:us-east-2:048908104884:cluster/mskLambdaStreamingCluster/*"
    }]
  })
}