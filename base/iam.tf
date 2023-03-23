resource "google_service_account" "sa04" {
  account_id   = "sa04-tf"
  display_name = "Service Account from TF task 4"
}

resource "google_project_iam_member" "sa04_rolebind" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.sa04.email}"
}

resource "google_service_account_iam_binding" "bind-admin-sa04" {
  service_account_id = google_service_account.sa04.name
  role               = "roles/iam.serviceAccountAdmin"

  members = [
    "user:admin@techplace.one",
  ]
}
