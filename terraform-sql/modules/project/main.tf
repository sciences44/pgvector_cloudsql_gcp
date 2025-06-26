// Create a new GCP project for all resources
resource "google_project" "main" {
  project_id      = var.project_id
  name            = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account
  deletion_policy = var.enable_project_deletion ? "DELETE" : "PREVENT"
  
  // Préserver le label de gestion Terraform
  labels = {
    "goog-terraform-provisioned" = "true"
    "environment"                = var.environment
  }
}

# Enable required services
resource "google_project_service" "services" {
  for_each = toset([
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])

  project = google_project.main.project_id
  service = each.value

  disable_dependent_services = true
  disable_on_destroy         = false
}
