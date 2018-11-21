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

resource "google_compute_firewall" "openshift_node_to_node" {
  name    = "openshift-node-to-node"
  network = "${google_compute_network.openshift.name}"

  # Required for SDN communication between pods on separate hosts.
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

  # Required for SDN communication between pods on separate hosts.
  allow {
    protocol = "udp"
    ports    = ["4789"]
  }

  # Required for node hosts to communicate to the master API, for the node hosts to post back status, to receive tasks, and so on.
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  # Required for DNS resolution of cluster services (SkyDNS).
  allow {
    protocol = "tcp"
    ports    = ["8053"]
  }

  # Required for DNS resolution of cluster services (SkyDNS).
  allow {
    protocol = "udp"
    ports    = ["8053"]
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
    ports    = ["443"]
  }

  # Port that the controller service listens on. Required to be open for the /metrics and /healthz endpoints.
  allow {
    protocol = "tcp"
    ports    = ["8444"]
  }

  target_tags = ["openshift-master"]
}

resource "google_compute_firewall" "ansible_controller_access" {
  name    = "ansible-controller-access"
  network = "${google_compute_network.openshift.name}"

  # External SSH access to controller
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["ansible-controller"]

  source_ranges = ["${var.ssh_ip_ranges}"]
}

resource "google_compute_firewall" "allow_https_and_ssh_egress_on_controller" {
  name    = "allow-https-ssh-egress-on-controller"
  network = "${google_compute_network.openshift.name}"

  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22"]
  }

  target_tags = ["ansible-controller"]
}

resource "google_compute_firewall" "allow_https_egress_on_openshift_nodes" {
  name    = "allow-https-egress-to-controller"
  network = "${google_compute_network.openshift.name}"

  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags = ["openshift-master", "openshift-node"]

  destination_ranges = ["${google_compute_instance.ansible_controller.network_interface.0.network_ip}/32"]
}

resource "google_compute_firewall" "ansible_controller_to_openshift" {
  name    = "ansible-controller-to-openshift"
  network = "${google_compute_network.openshift.name}"

  # SSH access
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["ansible-controller"]
  target_tags = ["openshift-master", "openshift-node"]

  source_ranges = []
}

resource "google_compute_firewall" "openshift_to_ansible_controller" {
  name    = "openshift-to-ansible-controller"
  network = "${google_compute_network.openshift.name}"

  # SSH access
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_tags = ["openshift-master", "openshift-node"]
  target_tags = ["ansible-controller"]

  source_ranges = []
}
