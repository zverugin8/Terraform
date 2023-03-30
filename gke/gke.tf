resource "google_container_cluster" "primary" {
  project            = var.project
  name               = "cluster1"
  location           = "us-central1-a"
  initial_node_count = var.nodes
  node_config {
    machine_type    = "e2-medium"
    disk_size_gb    = 50
    service_account = data.google_service_account.alchemy.email
    oauth_scopes = ["https://www.googleapis.com/auth/compute"]
    labels = {
      student = "${var.studentname}-${var.studentsurname}"
    }
    tags = [var.studentname, var.studentsurname]
  }
  timeouts {
    create = "30m"
    update = "40m"
  }
}
# #Create a GKE cluster
# resource "google_container_cluster" "my_cluster" {
#   name               = "my-cluster"
#   location           = "us-central1"
#   initial_node_count = 1
#   project            = var.project

#   node_config {
#     machine_type = "e2-medium"
#     disk_size_gb = 50
#     oauth_scopes = ["https://www.googleapis.com/auth/compute"]
#   }

#   #   master_auth {
#   #     username = ""
#   #     password = ""

#   #     client_certificate_config {
#   #       issue_client_certificate = false
#   #     }
#   #   }
# }

# # Create the first node pool
# resource "google_container_node_pool" "my_cluster_node_pool1" {
#   project    = var.project
#   name       = "node-pool1"
#   location   = "us-central1"
#   cluster    = google_container_cluster.my_cluster.name
#   node_count = 1
#   autoscaling {
#     min_node_count = 1
#     max_node_count = 1
#   }
#   node_config {
#     machine_type    = "e2-medium"
#     disk_size_gb    = 50
#     preemptible     = true
#     service_account = data.google_service_account.alchemy.account_id
#   }
#    timeouts {
#     create = "30m"
#     update = "40m"
#   }
# }

# # # Create the second node pool
# # resource "google_container_node_pool" "my_cluster_node_pool2" {
# #   project    = var.project
# #   name       = "node-pool2"
# #   location   = "us-central1"
# #   cluster    = google_container_cluster.my_cluster.name
# #   node_count = 1
# #   node_config {
# #     machine_type    = "n1-standard-4"
# #     disk_size_gb    = 50
# #     preemptible     = false
# #     service_account = data.google_service_account.alchemy.account_id
# #   }
# # }
