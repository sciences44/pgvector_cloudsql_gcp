variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "environment" {
  description = "The environment (dev, preprod, prod)"
  type        = string
}

variable "create_public_access" {
  description = "Whether to create public access firewall rules"
  type        = bool
  default     = false
}

variable "create_private_networking" {
  description = "Whether to create private networking resources (VPC, etc.)"
  type        = bool
  default     = true
}

variable "public_access_cidr" {
  description = "List of CIDR blocks for public access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
