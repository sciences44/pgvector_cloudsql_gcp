output "vpc_id" {
  value = var.create_private_networking ? google_compute_network.vector_database[0].id : null
}

output "vpc_name" {
  value = var.create_private_networking ? google_compute_network.vector_database[0].name : null
}

output "vpc_self_link" {
  value = var.create_private_networking ? google_compute_network.vector_database[0].self_link : null
}
