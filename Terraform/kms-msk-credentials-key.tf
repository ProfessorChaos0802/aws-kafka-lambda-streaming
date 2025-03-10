resource "aws_kms_key" "msk_credentials_key" {
  description         = "MSK Credentials Key"
  enable_key_rotation = true

  tags = {
    project = var.project
    owner   = var.owner
  }
}