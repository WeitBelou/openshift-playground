output "ansible_controller_external_ip" {
  value = "${google_compute_instance.ansible_controller.network_interface.0.access_config.0.nat_ip}"
}

output "ansible_controller_internal_ip" {
  value = "${google_compute_instance.ansible_controller.network_interface.0.network_ip}"
}

output "openshift_master_external_ip" {
  value = "${google_compute_instance.openshift_master.network_interface.0.access_config.0.nat_ip}"
}

output "openshift_master_internal_ip" {
  value = "${google_compute_instance.openshift_master.network_interface.0.network_ip}"
}

output "openshift_nodes_internal_ip" {
  value = "${google_compute_instance.openshift_nodes.*.network_interface.0.network_ip}"
}
