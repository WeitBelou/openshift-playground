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

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["ansible-controller"]

  source_ranges = ["${var.trusted_ip_ranges}"]
}

resource "google_compute_firewall" "ansible_controller_to_external_egress" {
  name    = "ansible-controller-to-external-egress"
  network = "${google_compute_network.openshift.name}"

  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags = ["ansible-controller"]

  destination_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "ansible_controller_to_openshift" {
  name    = "ansible-controller-to-openshift"
  network = "${google_compute_network.openshift.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["ansible-controller"]
  target_tags = ["openshift-master", "openshift-node"]

  source_ranges = []
}

resource "google_compute_firewall" "http_https_openshift_to_ansible_controller" {
  name    = "http-https-openshift-to-ansible-controller"
  network = "${google_compute_network.openshift.name}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_tags = ["openshift-master", "openshift-node"]
  target_tags = ["ansible-controller"]

  source_ranges = []
}

resource "google_compute_firewall" "openshift_to_yum_repo" {
  name    = "openshift-to-yum-repo"
  network = "${google_compute_network.openshift.name}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_tags = ["openshift-master", "openshift-node"]
  target_tags = ["yum-repo"]

  source_ranges = []
}

resource "google_compute_firewall" "openshift_to_docker_registry" {
  name    = "openshift-to-docker-registry"
  network = "${google_compute_network.openshift.name}"

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }

  source_tags = ["openshift-master", "openshift-node"]
  target_tags = ["docker-registry"]

  source_ranges = []
}

resource "google_compute_firewall" "openshift_node_to_node" {
  name    = "openshift-node-to-node"
  network = "${google_compute_network.openshift.name}"

  allow {
    protocol = "udp"
    ports    = ["4789"]
  }

  source_tags = ["openshift-node"]
  target_tags = ["openshift-node"]

  source_ranges = []
}

resource "google_compute_firewall" "openshift_node_to_master" {
  name    = "openshift-node-to-master"
  network = "${google_compute_network.openshift.name}"

  # Required for DNS resolution of cluster services (SkyDNS).
  allow {
    protocol = "udp"
    ports    = ["8053"]
  }

  # Required for DNS resolution of cluster services (SkyDNS).
  allow {
    protocol = "tcp"
    ports    = ["8053"]
  }

  # Required for SDN communication between pods on separate hosts.
  allow {
    protocol = "udp"
    ports    = ["4789"]
  }

  # Required for node hosts to communicate to the master API, for the node hosts to post back status, to receive tasks, and so on.
  allow {
    protocol = "tcp"
    ports    = ["443", "8443"]
  }

  source_tags = ["openshift-node"]
  target_tags = ["openshift-master"]

  source_ranges = []
}

resource "google_compute_firewall" "openshift_master_to_node" {
  name    = "openshift-master-to-node"
  network = "${google_compute_network.openshift.name}"

  # Required for SDN communication between pods on separate hosts.
  allow {
    protocol = "udp"
    ports    = ["4789"]
  }

  # The master proxies to node hosts via the Kubelet for oc commands.
  allow {
    protocol = "tcp"
    ports    = ["10250"]
  }

  source_tags = ["openshift-master"]
  target_tags = ["openshift-node"]

  source_ranges = []
}

resource "google_compute_firewall" "openshift_external_to_master" {
  name    = "openshift-external-to-master"
  network = "${google_compute_network.openshift.name}"

  # Required for node hosts to communicate to the master API, for node hosts to post back status, to receive tasks, and so on.
  allow {
    protocol = "tcp"
    ports    = ["443", "8443"]
  }

  # Port that the controller service listens on. Required to be open for the /metrics and /healthz endpoints.
  allow {
    protocol = "tcp"
    ports    = ["8444"]
  }

  target_tags = ["openshift-master"]

  source_ranges = ["${var.trusted_ip_ranges}"]
}
