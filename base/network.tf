resource "google_compute_network" "vpc_network" {
  name                    = "${local.StudentName}-${local.StudentSurname}-01-vpc"
  auto_create_subnetworks = false
}

