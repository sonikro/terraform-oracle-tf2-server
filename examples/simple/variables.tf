# ===========================================
# REQUIRED VARIABLES
# ===========================================

variable "compartment_id" {
  description = "The OCID of the OCI compartment where resources will be created"
  type        = string
}

variable "srcds_token" {
  description = "Steam Game Server Login Token (GSLT) - get one at https://steamcommunity.com/dev/managegameservers"
  type        = string
  sensitive   = true
}

variable "rcon_password" {
  description = "RCON password for remote server administration"
  type        = string
  sensitive   = true
}

# ===========================================
# OPTIONAL VARIABLES
# ===========================================

variable "freeform_tags" {
  description = "Freeform tags to apply to all resources"
  type        = map(string)
  default = {
    "project" = "tf2-servers"
  }
}
