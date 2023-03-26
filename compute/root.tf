terraform {
  backend "gcs" {
    bucket = "epam-gcp-tf-state-random"
    prefix = "terraform/state/compute"
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
  alias       = "task11"
  region      = "us-central1"
  zone        = "us-central1-a"
}

provider "google" {
  project     = jsondecode(file("/home/user1/.gcp/credentials.json"))["project_id"]
  credentials = file("/home/user1/.gcp/credentials.json")
  alias       = "soroka"
  region      = "us-west1"
  zone        = "us-west-b"
}
