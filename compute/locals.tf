locals {
  name    = data.terraform_remote_state.base.outputs.name
  surname = data.terraform_remote_state.base.outputs.surname
  regions = { 0 = "us-central1", 1 = "us-east1" }
  sa      = data.terraform_remote_state.base.outputs.service_account_email
  vpc     = data.terraform_remote_state.base.outputs.vpc_id
  bucket  = data.terraform_remote_state.base.outputs.bucket_id
  project = data.terraform_remote_state.base.outputs.project_metadata_id
  studentname    = "siarhei"
  studentsurname = "saroka"
}
