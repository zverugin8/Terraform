# startup script 
resource "local_file" "start" {
  content = templatefile("${path.module}/start.tpl", {
    mybucket = google_storage_bucket.task3_bucket.name
  })

  filename = "./start.sh"
}

# instance template
resource "google_compute_instance_template" "mig_template" {
  for_each = local.regions
  name     = "epam-gcp-tf-lab-${each.value}"

  machine_type = "f1-micro"
  tags         = ["web-instances"]
  project      = var.project

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
    network = local.vpc
    #subnetwork = data.terraform_remote_state.base.outputs.subnetworks_ids[each.key]
    subnetwork = local.subnets[each.key]
    access_config {
      network_tier = "PREMIUM"
    }
  }

  lifecycle {
    ignore_changes = [network_interface]
  }

  metadata_startup_script = file(local_file.start.filename)
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
  project = var.project
  name    = "static-ip"
}

# health check
resource "google_compute_health_check" "autohealing" {
  project             = var.project
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
  for_each           = local.regions
  project            = var.project
  name               = "epam-gcp-tf-lab-${each.value}"
  base_instance_name = "epam-gcp-tf-lab-${each.value}"
  target_size        = 1
  #zone               = "${local.regions[count.index]}-c"
  region = each.value

  version {
    instance_template = google_compute_instance_template.mig_template[each.key].id
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
  project               = var.project
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
  project         = var.project
  default_service = google_compute_backend_service.default.id
}

# http proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "tf-http-proxy"
  project = var.project
  url_map = google_compute_url_map.default.id
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "ft-forwarding-rule"
  project               = var.project
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}
