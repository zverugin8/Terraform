# data "terraform_remote_state" "base" {
#   backend = "gcs"
#   config = {
#     bucket      = "epam-gcp-tf-state-random"
#     prefix      = "terraform/state/base/"
#     credentials = "${file("/home/user1/.gcp/credentials.json")}"

#   }
# }

data "google_service_account" "sa04-tf" {
  account_id = "sa04-tf@saroka-gc-bootcamp.iam.gserviceaccount.com"
  project    = var.project
}

data "google_compute_network" "tf_vpc" {
  name    = "${var.studentname}-${var.studentsurname}-01-vpc"
  project = var.project
}

data "google_project" "current" {
  project_id = "saroka-gc-bootcamp"
}

data "google_compute_subnetwork" "us-central1" {
  project = var.project
  region  = "us-central1"
  name    = "siarhei-saroka-01-subnetwork-central"
}

data "google_compute_subnetwork" "us-east1" {
  project = var.project
  region  = "us-east1"
  name    = "siarhei-saroka-01-subnetwork-east"
}



