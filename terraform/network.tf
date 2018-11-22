resource "google_compute_network" "openshift" {
  name = "openshift"
}

resource "google_compute_firewall" "deny_all_egress" {
  name    = "deny-all-egress"
  network = "${google_compute_network.openshift.name}"

  priority = 1200

  direction = "EGRESS"

  deny {
    protocol = "all"
  }
}

resource "google_compute_firewall" "allow_network_egress" {
  name    = "allow-network-egress"
  network = "${google_compute_network.openshift.name}"

  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  destination_ranges = ["${var.subnetwork_cidr}"]
}

resource "google_compute_firewall" "external_to_ansible_controller" {
  name    = "external-to-ansible-controller"
  network = "${google_compute_network.openshift.name}"

  # External SSH access to controller
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["ansible-controller"]

  source_ranges = ["${var.trusted_ip_ranges}"]
}

resource "google_compute_firewall" "ansible_controller_to_openshift" {
  name    = "ansible-controller-to-openshift"
  network = "${google_compute_network.openshift.name}"

  # External SSH access to controller
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["ansible-controller"]
  target_tags = ["openshift-master", "openshift-node"]

  source_ranges = []
}
