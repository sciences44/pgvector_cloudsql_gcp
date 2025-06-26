variable "environment" {
  description = "The environment (dev, preprod, prod)"
  type        = string
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "db_instance_name" {
  description = "The name of the Cloud SQL instance."
  type        = string
}

variable "region" {
  description = "The region for the Cloud SQL instance."
  type        = string
  default     = "eu-west1"
}

variable "db_tier" {
  description = "The machine type to use."
  type        = string
  default     = "db-f1-micro"
}

variable "db_name" {
  description = "The name of the default database to create."
  type        = string
}

variable "db_user" {
  description = "The name of the default user."
  type        = string
}

variable "db_password" {
  description = "The password for the default user."
  type        = string
  sensitive   = true
}

variable "db_version" {
  description = "The version of PostgreSQL to use."
  type        = string
  default     = "POSTGRES_15"
}

variable "db_disk_size" {
  description = "The size of data disk in GB."
  type        = number
  default     = 10
}

variable "db_disk_type" {
  description = "The type of data disk: PD_SSD or PD_HDD."
  type        = string
  default     = "PD_SSD"
}

variable "db_availability_type" {
  description = "The availability type: ZONAL or REGIONAL."
  type        = string
  default     = "ZONAL"
}

variable "enable_public_ip" {
  description = "Enable public IP access for the Cloud SQL instance"
  type        = bool
  default     = false
}

variable "authorized_networks" {
  description = "List of CIDR blocks that are allowed to access the instance when public IP is enabled"
  type        = list(object({ name = string, value = string }))
  default     = []
}

variable "vpc_self_link" {
  description = "Self link of the VPC network"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Whether the instance is protected from deletion"
  type        = bool
  default     = false
}
