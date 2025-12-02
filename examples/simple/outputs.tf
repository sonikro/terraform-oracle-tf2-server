# ===========================================
# NETWORK OUTPUTS
# ===========================================

output "vcn_id" {
  description = "The OCID of the shared VCN"
  value       = module.network.vcn_id
}

output "subnet_id" {
  description = "The OCID of the shared subnet"
  value       = module.network.subnet_id
}

output "nsg_id" {
  description = "The OCID of the shared network security group"
  value       = module.network.nsg_id
}

# ===========================================
# ALL SERVERS SUMMARY
# ===========================================

output "servers" {
  description = "Summary of all deployed TF2 servers"
  value = {
    for key, server in module.tf2_servers : key => {
      name      = "tf2-${key}-server"
      public_ip = server.public_ip
    }
  }
}
