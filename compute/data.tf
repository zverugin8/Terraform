data "terraform_remote_state" "base" {
  backend = "local"
  config = {
    path = "/home/user1/tf-epam-lab/base/terraform.tfstate"
  }
}
