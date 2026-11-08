variable "environment" {
  type = string
  validation {
    condition     = contains(["test", "prod"], var.environment)
    error_message = "Environment must be test or prod."
  }
}
variable "config" {
  type = object({ name = string, replicas = number, database = bool, cache = bool })
}
variable "label" { type = map(string) }
variable "release" {
  type        = string
  default     = "v1-demo"
  description = "Set in Plinth to try template, environment, and run overrides. Not set in tfvars."
}
