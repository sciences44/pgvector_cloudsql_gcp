output "project_id" {
  value = module.project.project_id
}

output "instance_name" {
  value = module.sql.instance_name
}

output "database_name" {
  value = module.sql.database_name
}

output "public_ip_address" {
  value = module.sql.public_ip_address
  description = "Public IP address for the database (only available in dev environment)"
}
