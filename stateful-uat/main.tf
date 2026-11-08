# Synthetic local-cluster UAT only. Creates no cloud infrastructure.
terraform {
  required_version = ">= 1.6, < 2.0"
  backend "kubernetes" {
    secret_suffix    = "plinth-comprehensive-uat"
    namespace        = "plinth-runners"
    in_cluster_config = true
  }
}
variable "marker" {
  type = string
  sensitive = true
}
resource "terraform_data" "marker" {
  input = var.marker
  lifecycle {
    precondition {
      condition = file("/tmp/plinth-uat-marker") == "synthetic-file-content"
      error_message = "The synthetic credential file was not mounted correctly."
    }
  }
}
output "marker" {
  value = terraform_data.marker.output
  sensitive = true
}
