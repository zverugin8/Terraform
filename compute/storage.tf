resource "random_string" "rnd" {
  length  = 6
  special = false
  upper   = false
}

resource "google_storage_bucket" "task3_bucket" {
  name                        = "epam-gcp-tf-lab-${random_string.rnd.result}"
  location                    = "us-central1"
  storage_class               = "STANDARD"
  force_destroy               = true
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  labels = {
    terraform   = true
    epam-tf-lab = true
    tflab       = "task3"
    owner       = "${local.studentname}_${local.studentsurname}"
  }
}


# cd ~/tf-epam-lab/compute/
# tf state pull > compute.tfstate
# cd ~/tf-epam-lab/base/
# tf state pull > base.tfstate
# tf state mv -state=base.tfstate -state-out=../compute/compute.tfstate google_storage_bucket.task3_bucket google_storage_bucket.task3_bucket
# tf state mv -state=base.tfstate -state-out=../compute/compute.tfstate random_string.rnd random_string.rnd
# cd ~/tf-epam-lab/compute/
# tf state push ./compute.tfstate
# tf init
# mv ../base/storage.tf ./storage.tf
# echo "Dont forget move nessesary data from locals ""





