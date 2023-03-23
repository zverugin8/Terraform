terraform {}
provider "google" {
  project     = jsondecode(file("~/.gcp/credentials.json"))["project_id"]
  credentials = file("~/.gcp/credentials.json")
  region      = "us-central1"
  zone        = "us-central1-a"
}

