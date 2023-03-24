terraform {}
provider "google" {
  project     = jsondecode(file("/home/user1/.gcp/credentials.json"))["project_id"]
  credentials = file("/home/user1/.gcp/credentials.json")
  region      = "us-central1"
  zone        = "us-central1-a"
}

