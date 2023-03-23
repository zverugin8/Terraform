resource "google_compute_project_metadata" "project_metadata" {
  metadata = {
    shared_ssh_key = var.ssh_key
    ssh-keys       = "user1:${var.ssh_key}"

  }
}

# have to add env : export TF_VAR_ssh_key="YOUR_PUBLIC_SSH_KEY_STRING"
