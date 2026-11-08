variable "environment" { type = string }
variable "config" {
  type = object({ name = string, replicas = number, database = bool, cache = bool })
  validation {
    condition     = var.config.replicas >= 1 && var.config.replicas <= 5
    error_message = "Demo replicas must be between 1 and 5."
  }
}
variable "label" { type = map(string) }
variable "release" { type = string }
resource "terraform_data" "namespace" {
  input = { name = "${var.config.name}-${var.environment}", labels = var.label }
}
resource "terraform_data" "application" {
  input = { namespace = terraform_data.namespace.output.name, replicas = var.config.replicas, release = var.release }
}
resource "terraform_data" "database" {
  count = var.config.database ? 1 : 0
  input = { name = "${var.config.name}_${var.environment}", engine = "postgres-demo" }
}
resource "terraform_data" "cache" {
  count = var.config.cache ? 1 : 0
  input = { name = "${var.config.name}-${var.environment}", engine = "valkey-demo" }
}
output "summary" {
  value = { namespace = terraform_data.namespace.output.name, application = terraform_data.application.output, database = var.config.database, cache = var.config.cache }
}
