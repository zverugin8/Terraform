resource "google_compute_project_metadata" "project_metadata" {
  metadata = {
    shared_ssh_key = var.ssh_key
  }
}
