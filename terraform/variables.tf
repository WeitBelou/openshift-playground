variable "base_image" {
  description = "Base VM image for Openshift Nodes"
  default     = "rhel-7-v20181011"
}

variable "openshift_master_machine_type" {
  default = "custom-6-20480"
}

variable "openshift_node_machine_type" {
  default = "custom-2-10240"
}

variable "ansible_controller_machine_type" {
  default = "g1-small"
}

variable "openshift_nodes_count" {
  default = 2
}

variable "openshift_nodes_disk_size" {
  default = 40
}

variable "openshift_master_disk_size" {
  default = 60
}

variable "ssh_ip_ranges" {
  default = "0.0.0.0/0"
}
