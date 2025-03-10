data "aws_iam_policy_document" "msk_scram_secret_policy_document" {
  statement {
    sid    = "AllowSecretsManagerBasedAccess"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["kafka.amazonaws.com"]
    }

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      aws_secretsmanager_secret.msk_scram_secret.arn
    ]
  }
}