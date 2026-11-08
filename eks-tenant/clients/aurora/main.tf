module "tenant" {
  source      = "../../modules/tenant"
  environment = var.environment
  config      = var.config
  label       = var.label
  release     = var.release
}
