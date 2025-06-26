provider "google" {
  region = var.region
}

module "project" {
  source          = "../../modules/project"
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account
  environment     = "preprod"
}

# Full VPC setup for preprod, with private connectivity
module "vpc" {
  source                 = "../../modules/vpc"
  project_id             = module.project.project_id
  environment            = "preprod"
  create_public_access   = false  # No public access in preprod
  create_private_networking = true  # Use private networking for preprod
  public_access_cidr     = []       # No public CIDR ranges
}

module "sql" {
  source          = "../../modules/sql"
  environment     = "preprod"
  project_id      = module.project.project_id
  db_instance_name = var.db_instance_name
  region          = var.region
  db_tier         = var.db_tier
  db_name         = var.db_name
  db_user         = var.db_user
  db_password     = var.db_password
  vpc_self_link   = module.vpc.vpc_self_link
  
  # Preprod-specific settings
  enable_public_ip = false      # No public IP for preprod
  authorized_networks = []      # Empty authorized networks for preprod
  
  db_disk_size     = 20         # Larger disk for preprod
  db_availability_type = "ZONAL" # Single zone for preprod
  deletion_protection = false
}
