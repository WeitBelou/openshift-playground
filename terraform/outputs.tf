output "ansible_controller_external_ip" {
  value = "${google_compute_instance.ansible_controller.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "openshift_master_external_ip" {
  value = "${google_compute_instance.openshift_master.network_interface.0.access_config.0.assigned_nat_ip}"
}
