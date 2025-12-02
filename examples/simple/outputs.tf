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
# PAYLOAD SERVER OUTPUTS
# ===========================================

output "payload_server_public_ip" {
  description = "Public IP address of the Payload server"
  value       = module.tf2_payload_server.public_ip
}

output "payload_server_connect_command" {
  description = "Steam console command to connect to the Payload server"
  value       = module.tf2_payload_server.connect_command
}

# ===========================================
# CONTROL POINTS SERVER OUTPUTS
# ===========================================

output "cp_server_public_ip" {
  description = "Public IP address of the Control Points server"
  value       = module.tf2_cp_server.public_ip
}

output "cp_server_connect_command" {
  description = "Steam console command to connect to the Control Points server"
  value       = module.tf2_cp_server.connect_command
}

# ===========================================
# KING OF THE HILL SERVER OUTPUTS
# ===========================================

output "koth_server_public_ip" {
  description = "Public IP address of the KOTH server"
  value       = module.tf2_koth_server.public_ip
}

output "koth_server_connect_command" {
  description = "Steam console command to connect to the KOTH server"
  value       = module.tf2_koth_server.connect_command
}

# ===========================================
# ALL SERVERS SUMMARY
# ===========================================

output "all_servers" {
  description = "Summary of all deployed TF2 servers"
  value = {
    payload = {
      name            = "tf2-payload-server"
      public_ip       = module.tf2_payload_server.public_ip
      connect_command = module.tf2_payload_server.connect_command
    }
    control_points = {
      name            = "tf2-cp-server"
      public_ip       = module.tf2_cp_server.public_ip
      connect_command = module.tf2_cp_server.connect_command
    }
    koth = {
      name            = "tf2-koth-server"
      public_ip       = module.tf2_koth_server.public_ip
      connect_command = module.tf2_koth_server.connect_command
    }
  }
}
