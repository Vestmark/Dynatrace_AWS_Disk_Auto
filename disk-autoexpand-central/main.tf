locals {
  project_name = "disk-autoexpand"

  common_tags = {
    Project     = "DiskAutoExpansion"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}