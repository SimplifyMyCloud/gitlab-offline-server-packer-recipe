# Foundation Layer - GCP Ops - Gitlab Offline Server Desired State - VPC Network & Subnet
# Infrastructure base name = gitlab-tf-org-ops-{asset}
resource "google_compute_network" "vpc" {
  name = "gitlab-tf-org-ops-vpc"
  description = "VPC network to host the Terraform Server MIG ensuring the GCP Org Ops"
  auto_create_subnetworks = false
  routing_mode = "REGIONAL"
  project = "simplifymycloud-dev"
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "subnet" {
  name = "gitlab-tf-org-ops-subnet"
  description = "Subnetwork to host the Terraform Server MIG ensuring the GCP Org Ops"
  network = "gitlab-tf-org-ops-vpc"
  private_ip_google_access = 
  region = "us-west1-c"
  ip_cidr_range = "10.0.0.0/29"
}