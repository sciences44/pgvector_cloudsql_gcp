# VPC module for private networking (preprod/prod)
# Only create VPC resources when private networking is needed
resource "google_compute_network" "vector_database" {
  count                   = var.create_private_networking ? 1 : 0
  name                    = "${var.environment}-vector-database"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_global_address" "private_ip_range" {
  count         = var.create_private_networking ? 1 : 0
  name          = "${var.environment}-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vector_database[0].id
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  count                  = var.create_private_networking ? 1 : 0
  network                 = google_compute_network.vector_database[0].id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range[0].name]
}

# Internal traffic firewall rule
resource "google_compute_firewall" "vector_allow_internal" {
  count         = var.create_private_networking ? 1 : 0
  name          = "${var.environment}-vector-allow-internal"
  network       = google_compute_network.vector_database[0].name
  project       = var.project_id
  description   = "Allow internal traffic on the vector network"
  direction     = "INGRESS"
  priority      = 65534
  source_ranges = ["10.128.0.0/9"]
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
}

# SSH access firewall rule (can be limited to specific IPs in preprod/prod)
resource "google_compute_firewall" "vector_allow_ssh" {
  count         = var.create_private_networking && var.create_public_access ? 1 : 0
  name          = "${var.environment}-vector-allow-ssh"
  network       = google_compute_network.vector_database[0].name
  project       = var.project_id
  description   = "Allow SSH from specified ranges"
  direction     = "INGRESS"
  priority      = 65534
  source_ranges = var.public_access_cidr
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
