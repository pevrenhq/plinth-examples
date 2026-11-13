# Synthetic local-cluster UAT only. Logs in to a Vault dev server with the run's Plinth OIDC token.
terraform {
  required_version = ">= 1.6, < 2.0"
  required_providers {
    http  = { source = "hashicorp/http", version = "~> 3.4" }
    local = { source = "hashicorp/local", version = "~> 2.5" }
    time  = { source = "hashicorp/time", version = "~> 0.12" }
  }
}

variable "vault_addr" {
  type    = string
  default = "http://vault.plinth-uat-vault.svc:8200"
}

variable "role" {
  type    = string
  default = "plinth"
}

variable "token_file" {
  type    = string
  default = "/plinth/oidc/aws/token"
}

variable "apply_wait" {
  type    = string
  default = "0s"
}

data "http" "plan_login" {
  url          = "${var.vault_addr}/v1/auth/jwt/login"
  method       = "POST"
  request_body = sensitive(jsonencode({ role = var.role, jwt = trimspace(file(var.token_file)) }))
}

resource "time_sleep" "wait" {
  create_duration = var.apply_wait
  triggers        = { run = timestamp() }
}

data "local_sensitive_file" "apply_token" {
  filename   = var.token_file
  depends_on = [time_sleep.wait]
}

data "http" "apply_login" {
  url          = "${var.vault_addr}/v1/auth/jwt/login"
  method       = "POST"
  request_body = jsonencode({ role = var.role, jwt = trimspace(data.local_sensitive_file.apply_token.content) })
}

output "plan_login_status" {
  value = data.http.plan_login.status_code
}

output "plan_login_metadata" {
  value = try(jsondecode(data.http.plan_login.response_body).auth.metadata, null)
}

output "apply_login_status" {
  value = data.http.apply_login.status_code
}

output "apply_login_metadata" {
  value = try(jsondecode(data.http.apply_login.response_body).auth.metadata, null)
}
