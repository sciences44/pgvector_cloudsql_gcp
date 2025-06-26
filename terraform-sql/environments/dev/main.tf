provider "google" {
  region = var.region
}

module "project" {
  source                = "../../modules/project"
  project_id            = var.project_id
  org_id                = var.org_id
  billing_account       = var.billing_account
  environment           = "dev"
  enable_project_deletion = true  # Allow project deletion for dev environment
}

# VPC is minimal for dev as public access is used
module "vpc" {
  source                  = "../../modules/vpc"
  project_id              = module.project.project_id
  environment             = "dev"
  create_public_access    = true  # Allow public access in dev
  create_private_networking = false  # Skip private networking for dev
  public_access_cidr      = ["0.0.0.0/0"]  # Open to all IPs for dev ease of use
}

module "sql" {
  source          = "../../modules/sql"
  environment     = "dev"
  project_id      = module.project.project_id
  db_instance_name = var.db_instance_name
  region          = var.region
  db_tier         = var.db_tier
  db_name         = var.db_name
  db_user         = var.db_user
  db_password     = var.db_password
  vpc_self_link   = null  # No VPC needed for dev with public IP
  
  # Dev-specific settings
  enable_public_ip = true  # Public IP for development
  authorized_networks = [
    {
      name  = "all-access"
      value = "0.0.0.0/0"  # In production, you'd limit this to specific IPs
    }
  ]
  
  db_disk_size     = 10  # Smaller disk for dev
  deletion_protection = false
}
