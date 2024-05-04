resource "aws_secretsmanager_secret" "app_secrets" {
  name        = "${var.environment}-app-secrets"
  description = "app-secrets"
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id     = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    ## TODO SECRET_SAMPLEは動作確認用なので、あとで削除する
    SECRET_SAMPLE = var.secret_sample
    DB_PASSWORD = var.db_password
  })
}
