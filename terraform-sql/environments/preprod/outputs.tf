output "project_id" {
  value = module.project.project_id
}

output "instance_name" {
  value = module.sql.instance_name
}

output "database_name" {
  value = module.sql.database_name
}

output "private_ip_address" {
  value = module.sql.private_ip_address
  description = "Private IP address for database connectivity"
}
