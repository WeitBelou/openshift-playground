resource "null_resource" "ansible_files" {
  triggers {
    "always" = "${uuid()}"
  }

  connection {
    host = "${google_compute_instance.ansible_controller.network_interface.0.access_config.0.assigned_nat_ip}"

    user        = "openshift"
    private_key = "${file("~/.ssh/id_rsa_openshift")}"
  }

  provisioner "file" {
    source      = "../ansible"
    destination = "~"
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

  provisioner "file" {
    source      = "~/.ssh/id_rsa_openshift"
    destination = "~/.ssh/id_rsa_openshift"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 ~/.ssh/id_rsa_openshift",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "cd ansible",
      "ansible-playbook playbooks/run_installer.yml",
    ]
  }
}
