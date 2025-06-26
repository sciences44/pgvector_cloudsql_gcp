variable "project_id" {
  description = "The GCP project ID to create and use for all resources."
  type        = string
}

variable "region" {
  description = "The region for the Cloud SQL instance."
  type        = string
  default     = "eu-west1"
}

variable "org_id" {
  description = "The GCP organization ID."
  type        = string
}

variable "billing_account" {
  description = "The GCP billing account ID."
  type        = string
}

variable "db_instance_name" {
  description = "The name of the Cloud SQL instance."
  type        = string
}

variable "db_tier" {
  description = "The machine type to use."
  type        = string
  default     = "db-custom-2-8192" # Higher specs for preprod
}

variable "db_name" {
  description = "The name of the default database to create."
  type        = string
  default     = "mydatabase"
}

variable "db_user" {
  description = "The name of the default user."
  type        = string
  default     = "myuser"
}

variable "db_password" {
  description = "The password for the default user."
  type        = string
  sensitive   = true
  default     = "your-secure-password"
}
