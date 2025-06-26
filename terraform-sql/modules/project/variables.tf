variable "project_id" {
  description = "The GCP project ID to create and use for all resources."
  type        = string
}

variable "org_id" {
  description = "The GCP organization ID."
  type        = string
}

variable "billing_account" {
  description = "The GCP billing account ID."
  type        = string
}

variable "environment" {
  description = "The environment (dev, preprod, prod)"
  type        = string
}

variable "enable_project_deletion" {
  description = "Whether to allow deletion of the project when running terraform destroy"
  type        = bool
  default     = false
}
