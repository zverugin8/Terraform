resource "google_compute_network" "tf_vpc" {
  name                    = "${local.studentname}-${local.studentsurname}-01-vpc"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "subnet_central" {
  name          = "${local.studentname}-${local.studentsurname}-01-subnetwork-central"
  ip_cidr_range = "10.10.1.0/24"
  network       = google_compute_network.tf_vpc.self_link
  region        = "us-central1"
}

resource "google_compute_subnetwork" "subnet_east" {
  name          = "${local.studentname}-${local.studentsurname}-01-subnetwork-east"
  ip_cidr_range = "10.10.3.0/24"
  network       = google_compute_network.tf_vpc.self_link
  region        = "us-east1"
}
