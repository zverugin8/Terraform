data "terraform_remote_state" "base" {
  backend = "gcs"
  config = {
    bucket  = "epam-gcp-tf-state-random"
    prefix  = "terraform/state/base/"
    credentials = "${file("/home/user1/.gcp/credentials.json")}"
    
  }
}