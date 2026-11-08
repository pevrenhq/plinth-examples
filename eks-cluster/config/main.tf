module "cluster" {
  source      = "../module"
  environment = var.environment
  node_count  = var.node_count
}
