data "google_project" "project" {}

resource "template_dir" "ansible" {
  source_dir      = "../ansible"
  destination_dir = "/tmp/ansible"

  vars {
    openshift_master_fqdn = "${google_compute_instance.openshift_master.name}.${google_compute_instance.openshift_master.zone}.c.${data.google_project.project.id}.internal"
    openshift_node_1_fqdn = "${google_compute_instance.openshift_nodes.0.name}.${google_compute_instance.openshift_nodes.0.zone}.c.${data.google_project.project.id}.internal"
    openshift_node_2_fqdn = "${google_compute_instance.openshift_nodes.1.name}.${google_compute_instance.openshift_nodes.1.zone}.c.${data.google_project.project.id}.internal"

    ansible_controller_internal_ip = "${google_compute_instance.ansible_controller.network_interface.0.network_ip}"
  }
}

resource "null_resource" "ansible_files" {
  triggers {
    "always" = "${uuid()}"
  }

  connection {
    host = "${google_compute_instance.ansible_controller.network_interface.0.access_config.0.assigned_nat_ip}"

    user        = "ansible_user"
    private_key = "${file("~/.ssh/id_rsa_ansible_user")}"
  }

  provisioner "file" {
    source      = "~/.ssh/id_rsa_ansible_user"
    destination = "~/.ssh/id_rsa_ansible_user"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 ~/.ssh/id_rsa_ansible_user",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "[ -d ~/ansible ] || rm -rf ~/ansible",
    ]
  }

  provisioner "file" {
    source      = "${template_dir.ansible.destination_dir}"
    destination = "~"
  }

  provisioner "local-exec" {
    command = "rm -rf ${template_dir.ansible.destination_dir}"
  }

  provisioner "remote-exec" {
    inline = [
      "[ -d ~/.vault_keys ] || mkdir -p ~/.vault_keys",
    ]
  }

  provisioner "file" {
    source      = "~/.vault_keys/openshift_playground"
    destination = "~/.vault_keys/openshift_playground"
  }
}
