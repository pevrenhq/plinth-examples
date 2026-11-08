variable "environment" { type = string }
variable "node_count" { type = number }
resource "terraform_data" "network" {
  input = { name = "demo-${var.environment}", cidr = "10.99.0.0/16" }
}
resource "terraform_data" "cluster" {
  input = { network = terraform_data.network.output.name, nodes = var.node_count }
}
output "summary" { value = terraform_data.cluster.output }
