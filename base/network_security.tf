resource "google_compute_firewall" "ssh_inbound" {
  name          = "ssh-inbound"
  network       = google_compute_network.tf_vpc.name
  description   = "allows ssh access from safe IP-range"
  direction     = "INGRESS"
  source_ranges = ["103.90.163.98/32", "212.98.166.103/32", "35.235.240.0/20"]
  target_tags   = ["web-instances"]
  depends_on    = [google_compute_network.tf_vpc]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

}

resource "google_compute_firewall" "http_inbound" {
  name          = "http-inbound"
  network       = google_compute_network.tf_vpc.name
  description   = "allows http access from LoadBalancer"
  direction     = "INGRESS"
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "0.0.0.0/0"]
  target_tags   = ["web-instances"]
  depends_on    = [google_compute_network.tf_vpc]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

}
