terraform { required_version = ">= 1.6, < 2.0" }
variable "message" {
  type    = string
  default = "synthetic-output-uat"
}
output "message" { value = var.message }
