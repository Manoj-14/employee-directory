resource "aws_secretsmanager_secret" "secret" {
    name  = "${var.project_name}/${var.environment}/${var.secret_name}"
}

resource "aws_secretsmanager_secret_version" "instance-ssh-key" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = tls_private_key.ssh_key.private_key_pem
}
