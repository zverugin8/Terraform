output "name" {
  value = local.name
}

output "balancer_address" {
  value = google_compute_global_address.default.address
}


output "subnet" {
  value = local.subnets
}

output "nodes" {
  value = var.nodes
}

