locals {
  name    = var.studentname
  surname = var.studentsurname
  regions = var.regions
  sa      = data.google_service_account.sa04-tf.email
  vpc     = data.google_compute_network.tf_vpc.name
  project = data.google_project.current.id
  subnets = [data.google_compute_subnetwork.us-central1.id, data.google_compute_subnetwork.us-east1.id]
}
