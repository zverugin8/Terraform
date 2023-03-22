terraform {}
provider "google" {
  project     = "saroka-gc-bootcamp"
  credentials = file("~/.gcp/credentials.json")
  region      = "us-central1"
  zone        = "us-central1-a"
}

