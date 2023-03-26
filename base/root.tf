terraform {
  backend "gcs" {
    bucket = "epam-gcp-tf-state-random"
    prefix = "terraform/state/base"
  }
  required_providers {
    local = {
      version = "~> 2.1"
    }
  }
}
provider "google" {
  project     = jsondecode(file("/home/user1/.gcp/credentials.json"))["project_id"]
  credentials = file("/home/user1/.gcp/credentials.json")
  region      = "us-central1"
  zone        = "us-central1-a"
}

