resource "google_compute_instance" "ansible_controller" {
  name = "ansible-controller"

  boot_disk {
    initialize_params {
      image = "${var.base_image}"
    }
  }

  network_interface {
    network = "${google_compute_network.openshift.name}"
  }

  tags = ["ansible-controller"]
}

resource "google_compute_instance" "openshift_master" {
  name = "openshift-master"

  boot_disk {
    initialize_params {
      image = "${var.base_image}"
      size  = "${var.openshift_master_disk_size}"
    }
  }

  network_interface {
    network = "${google_compute_network.openshift.name}"
  }

  tags = ["openshift-master"]
}

resource "google_compute_instance" "openshift_nodes" {
  count = "${var.openshift_nodes_count}"
  name  = "openshift-node-${count.index + 1}"

  boot_disk {
    initialize_params {
      image = "${var.base_image}"
      size  = "${var.openshift_nodes_disk_size}"
    }
  }

  network_interface {
    network = "${google_compute_network.openshift.name}"
  }

  tags = ["openshift-node"]
}
