# startup script 
resource "local_file" "start" {
  content = templatefile("${path.module}/start.tpl", {
    mybucket = local.bucket
  })

  filename = "./start.sh"
}

# instance template
resource "google_compute_instance_template" "mig_template" {
  count = length(local.regions)
  name  = "epam-gcp-tf-lab-${local.regions[count.index]}"

  machine_type = "f1-micro"
  tags         = ["web-instances"]

  labels = {
    terraform = true,
    project   = "epam-tf-lab",
    owner     = "${local.name}_${local.surname}"
  }

  disk {
    source_image = "debian-cloud/debian-10"
  }

  service_account {
    email  = local.sa
    scopes = ["userinfo-email", "compute-ro", "storage-rw"]
  }

  network_interface {
    network    = local.vpc
    subnetwork = data.terraform_remote_state.base.outputs.subnetworks_ids[count.index]
    access_config {
      network_tier = "PREMIUM"
    }
  }

  lifecycle {
    ignore_changes = [network_interface]
  }

  metadata_startup_script = local_file.start.id
#   metadata = {
#     "startup-script" = <<EOF
# #!/bin/bash
# set -ex
# apt update
# apt-get install nginx -y
# INSTANCE_ID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/id" -H "Metadata-Flavor: Google")
# VM_MACHINE_UUID=$(sudo cat /sys/devices/virtual/dmi/id/product_uuid |tr '[:upper:]' '[:lower:]')
# echo "This message was generated on instance $INSTANCE_ID with the following UUID $VM_MACHINE_UUID" > $INSTANCE_ID.txt
# gsutil cp ./$INSTANCE_ID.txt gs://${local.bucket}
# cp ./$INSTANCE_ID.txt /var/www/html/index.html
# echo "Done!"
# EOF
#   }
}

# reserved IP address
resource "google_compute_global_address" "default" {
  name = "static-ip"
}

# health check
resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/"
    port         = "80"
  }
}

resource "google_compute_region_instance_group_manager" "appserver" {
  count              = length(local.regions)
  name               = "epam-gcp-tf-lab-${local.regions[count.index]}"
  base_instance_name = "epam-gcp-tf-lab-${local.regions[count.index]}"
  target_size        = 1
  #zone               = "${local.regions[count.index]}-c"
  region = local.regions[count.index]

  version {
    instance_template = google_compute_instance_template.mig_template[count.index].id
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.self_link
    initial_delay_sec = 300
  }
}

# backend service
resource "google_compute_backend_service" "default" {
  name                  = "backend-service"
  protocol              = "HTTP"
  timeout_sec           = 10
  enable_cdn            = true
  load_balancing_scheme = "EXTERNAL"
  port_name             = "http"
  health_checks         = [google_compute_health_check.autohealing.id]

  backend {
    group = google_compute_region_instance_group_manager.appserver[0].instance_group
  }

  backend {
    group = google_compute_region_instance_group_manager.appserver[1].instance_group
  }
}

# url map
resource "google_compute_url_map" "default" {
  name            = "tf-url-map"
  default_service = google_compute_backend_service.default.id
}

# http proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "tf-http-proxy"
  url_map = google_compute_url_map.default.id
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "ft-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}
