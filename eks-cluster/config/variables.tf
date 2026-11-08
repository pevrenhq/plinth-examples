variable "environment" { type = string }
variable "node_count" {
  type    = number
  default = 2
  validation {
    condition     = var.node_count >= 1 && var.node_count <= 4
    error_message = "Demo node_count must be between 1 and 4. Try 0 to test a failed plan."
  }
}
