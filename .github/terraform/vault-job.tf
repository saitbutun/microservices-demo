resource "random_password" "redis_pass" {
  length  = 16
  special = false
  upper   = true
}

resource "random_password" "db_pass" {
  length  = 16
  special = false
  upper   = true
}

resource "local_file" "vault_job_file" {
  content = templatefile("${path.module}/vault-bootstrap.tftpl", {
    redis_password_placeholder = random_password.redis_pass.result
    db_password_placeholder    = random_password.db_pass.result
  })

  filename = "${path.module}/vault-bootstrap-generated.yaml"
}