resource "google_compute_network" "vpc_network" {
  name                    = "${local.studentname}-${local.studentsurname}-01-vpc"
  auto_create_subnetworks = false
}

