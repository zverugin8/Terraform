output "vpc_id" {
  value = google_compute_network.tf_vpc.id
}

output "subnetworks_ids" {
  value = [google_compute_subnetwork.subnet_central.id, google_compute_subnetwork.subnet_east.id]
}

output "service_account_email" {
  value = google_service_account.sa04.email
}

output "project_metadata_id" {
  value = google_compute_project_metadata.project_metadata.id
}

# output "bucket_id" {
#   value = google_storage_bucket.task3_bucket.id
# }

output "name" {
  value = local.studentname
}

output "surname" {
  value = local.studentsurname
}

output "project_number" {
  value = data.google_project.current.number
}

output "default_sa" {
  value = data.google_app_engine_default_service_account.default.email
}
output "regions" {
  value = data.google_compute_regions.default
}

