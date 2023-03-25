output "name" {
  value = local.name
  }

output "balancer_address" {
 value = google_compute_global_address.default.address
}
