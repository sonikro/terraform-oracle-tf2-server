output "vcn_id" {
  description = "The OCID of the VCN"
  value       = oci_core_virtual_network.vcn.id
}

output "subnet_id" {
  description = "The OCID of the public subnet"
  value       = oci_core_subnet.public_subnet.id
}

output "subnet_cidr_block" {
  description = "The CIDR block of the subnet"
  value       = oci_core_subnet.public_subnet.cidr_block
}

output "nsg_id" {
  description = "The OCID of the network security group"
  value       = oci_core_network_security_group.nsg.id
}

output "internet_gateway_id" {
  description = "The OCID of the internet gateway"
  value       = oci_core_internet_gateway.igw.id
}

output "route_table_id" {
  description = "The OCID of the route table"
  value       = oci_core_route_table.public_rt.id
}

output "availability_domain" {
  description = "The availability domain used for the subnet"
  value       = local.availability_domain
}
