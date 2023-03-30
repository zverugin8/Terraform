terraform {
  backend "gcs" {
    bucket = "epam-gcp-tf-state-random"
    prefix = "terraform/state/gke"
  }
  required_providers {
    local = {
      version = "~> 2.1"
    }
  }

}
provider "google" {
  project     = var.project
  credentials = file("/home/user1/.gcp/credentials.json")
  alias       = "gke"
  region      = "us-central1"
  zone        = "us-central1-a"
}

