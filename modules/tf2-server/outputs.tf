output "container_instance_id" {
  description = "The OCID of the container instance"
  value       = oci_container_instances_container_instance.tf2_server.id
}

output "container_instance_state" {
  description = "The current state of the container instance"
  value       = oci_container_instances_container_instance.tf2_server.state
}

output "public_ip" {
  description = "The public IP address of the container instance"
  value       = data.oci_core_vnic.tf2_vnic.public_ip_address
}

output "private_ip" {
  description = "The private IP address of the container instance"
  value       = data.oci_core_vnic.tf2_vnic.private_ip_address
}

output "vnic_id" {
  description = "The OCID of the VNIC"
  value       = data.oci_core_vnic.tf2_vnic.id
}

output "server_address" {
  description = "The full server address to connect to (IP:port)"
  value       = "${data.oci_core_vnic.tf2_vnic.public_ip_address}:27015"
}

output "connect_command" {
  description = "Steam console command to connect to the server"
  value       = "connect ${data.oci_core_vnic.tf2_vnic.public_ip_address}:27015"
}
