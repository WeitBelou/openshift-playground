resource "google_compute_instance" "ansible_controller" {
  name = "ansible-controller"

  machine_type = "${var.ansible_controller_machine_type}"

  allow_stopping_for_update = true

  metadata {
    sshKeys = "ansible_user:${file("~/.ssh/id_rsa_ansible_user.pub")}"
  }

  metadata_startup_script = "sudo yum -y install ansible"

  boot_disk {
    initialize_params {
      image = "${var.base_image}"
      size  = 146
    }
  }

  network_interface {
    access_config {}

    network = "${google_compute_network.openshift.name}"
  }

  tags = ["ansible-controller", "yum-repo", "docker-registry"]
}

resource "google_compute_instance" "openshift_master" {
  name = "openshift-master"

  machine_type = "${var.openshift_master_machine_type}"

  metadata {
    sshKeys = "ansible_user:${file("~/.ssh/id_rsa_ansible_user.pub")}"
  }

  boot_disk {
    initialize_params {
      image = "${var.base_image}"
      size  = "${var.openshift_master_disk_size}"
    }
  }

  network_interface {
    access_config {}

    network = "${google_compute_network.openshift.name}"
  }

  tags = ["openshift-master"]
}

resource "google_compute_instance" "openshift_nodes" {
  count = "${var.openshift_nodes_count}"
  name  = "openshift-node-${count.index + 1}"

  metadata {
    sshKeys = "ansible_user:${file("~/.ssh/id_rsa_ansible_user.pub")}"
  }

  machine_type = "${var.openshift_node_machine_type}"

  boot_disk {
    initialize_params {
      image = "${var.base_image}"
      size  = "${var.openshift_nodes_disk_size}"
    }
  }

  network_interface {
    access_config {}

    network = "${google_compute_network.openshift.name}"
  }

  tags = ["openshift-node"]
}
