resource "aws_secretsmanager_secret" "msk_scram_secret" {
  name       = "AmazonMSK_SCRAM"
  kms_key_id = aws_kms_key.msk_credentials_key.arn
}

resource "aws_secretsmanager_secret_version" "msk_scram_secret_value" {
  secret_id = aws_secretsmanager_secret.msk_scram_secret.id
  secret_string = jsonencode({
    username = var.msk_user
    password = var.msk_password
  })
}

resource "aws_secretsmanager_secret_policy" "msk_scram_secret_policy" {
  secret_arn = aws_secretsmanager_secret.msk_scram_secret.arn
  policy     = data.aws_iam_policy_document.msk_scram_secret_policy_document.json
}

resource "aws_msk_scram_secret_association" "msk_scram_secret_association" {
  cluster_arn = aws_msk_cluster.msk_lambda_streaming_cluster.arn
  secret_arn_list = [
    aws_secretsmanager_secret.msk_scram_secret.arn
  ]
}