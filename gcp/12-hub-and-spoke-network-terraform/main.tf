variable "project_id" {}
variable "environment" {}

provider "google" {
  project = var.project_id
  region = "us-central1"
}

# 1. Hub VPC (Central Connectivity & Shared Services)
resource "google_compute_network" "hub_vpc" {
  name = "vpc-hub-${var.environment}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "hub_shared" {
  name = "snet-hub-shared-${var.environment}"
  ip_cidr_range = "10.0.2.0/24"
  region = "us-central1"
  network = google_compute_network.hub_vpc.id
}

# 2. Spoke 1 VPC (Application Tier)
resource "google_compute_network" "spoke_app_vpc" {
    name = "vpc-spoke-app-${var.environment}"
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "spoke_app_subnet" {
    name = "snet-spoke-app-${var.environment}"
    ip_cidr_range = "10.1.1.0/24"
    region = "us-central1"
    network = google_compute_network.spoke_app_vpc.id
}

# 3. Spoke 2 VPC (Database Tier)
resource "google_compute_network" "spoke_data_vpc" {
  name                    = "vpc-spoke-data-${var.environment}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "spoke_data_subnet" {
  name          = "snet-spoke-data-${var.environment}"
  ip_cidr_range = "10.2.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.spoke_data_vpc.id
}

# 4. Bidirectional VPC Peering: Hub <-> Spoke App
resource "google_compute_network_peering" "hub_to_spoke_app" {
  name         = "peer-hub-to-spoke-app"
  network      = google_compute_network.hub_vpc.self_link
  peer_network = google_compute_network.spoke_app_vpc.self_link
}

resource "google_compute_network_peering" "spoke_app_to_hub" {
  name         = "peer-spoke-app-to-hub"
  network      = google_compute_network.spoke_app_vpc.self_link
  peer_network = google_compute_network.hub_vpc.self_link
}

# 5. Bidirectional VPC Peering: Hub <-> Spoke Data (Sequenced to avoid GCP network lock conflicts)
resource "google_compute_network_peering" "hub_to_spoke_data" {
  name         = "peer-hub-to-spoke-data"
  network      = google_compute_network.hub_vpc.self_link
  peer_network = google_compute_network.spoke_data_vpc.self_link

  depends_on = [
    google_compute_network_peering.hub_to_spoke_app,
    google_compute_network_peering.spoke_app_to_hub
  ]
}

resource "google_compute_network_peering" "spoke_data_to_hub" {
  name         = "peer-spoke-data-to-hub"
  network      = google_compute_network.spoke_data_vpc.self_link
  peer_network = google_compute_network.hub_vpc.self_link

  depends_on = [
    google_compute_network_peering.hub_to_spoke_app,
    google_compute_network_peering.spoke_app_to_hub
  ]
}