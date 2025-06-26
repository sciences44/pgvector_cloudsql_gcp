provider "google" {
  region = var.region
}

module "project" {
  source          = "../../modules/project"
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account
  environment     = "prod"
}

# Full VPC setup for production, with private connectivity only
module "vpc" {
  source                 = "../../modules/vpc"
  project_id             = module.project.project_id
  environment            = "prod"
  create_public_access   = false  # No public access in prod
  create_private_networking = true  # Use private networking for prod
  public_access_cidr     = []       # No public CIDR ranges
}

module "sql" {
  source          = "../../modules/sql"
  environment     = "prod"
  project_id      = module.project.project_id
  db_instance_name = var.db_instance_name
  region          = var.region
  db_tier         = var.db_tier
  db_name         = var.db_name
  db_user         = var.db_user
  db_password     = var.db_password
  vpc_self_link   = module.vpc.vpc_self_link
  
  # Production-specific settings
  enable_public_ip = false      # No public IP for production
  authorized_networks = []      # Empty authorized networks for production
  
  db_disk_size     = 50         # Larger disk for production
  db_availability_type = "REGIONAL" # Regional for high availability
  deletion_protection = true     # Protect from accidental deletion
}
