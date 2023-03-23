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
