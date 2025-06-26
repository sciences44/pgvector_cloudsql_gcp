resource "google_sql_database_instance" "postgres_instance" {
  name                = "${var.environment}-${var.db_instance_name}"
  database_version    = var.db_version
  region              = var.region
  project             = var.project_id
  deletion_protection = var.deletion_protection

  settings {
    edition           = "ENTERPRISE"
    tier              = var.db_tier
    disk_size         = var.db_disk_size
    disk_type         = var.db_disk_type
    availability_type = var.db_availability_type
    
    ip_configuration {
      ipv4_enabled    = var.enable_public_ip
      private_network = var.enable_public_ip ? null : var.vpc_self_link
      
      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.value
        }
      }
    }
    
    backup_configuration {
      enabled = var.environment == "prod" ? true : false
      # Add additional backup settings for prod if needed
    }
  }
}

resource "google_sql_database" "default" {
  name       = var.db_name
  instance   = google_sql_database_instance.postgres_instance.name
  project    = var.project_id
}

resource "google_sql_user" "default" {
  name       = var.db_user
  instance   = google_sql_database_instance.postgres_instance.name
  password   = var.db_password
  project    = var.project_id
}
