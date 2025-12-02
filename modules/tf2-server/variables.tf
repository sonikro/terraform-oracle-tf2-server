# ===========================================
# REQUIRED VARIABLES
# ===========================================

variable "compartment_id" {
  description = "The OCID of the compartment"
  type        = string
}

variable "server_name" {
  description = "Name for the TF2 server (used for resource naming)"
  type        = string
}

variable "availability_domain" {
  description = "The availability domain for the container instance"
  type        = string
}

variable "subnet_id" {
  description = "The OCID of the subnet"
  type        = string
}

# ===========================================
# NETWORK CONFIGURATION
# ===========================================

variable "nsg_ids" {
  description = "List of network security group OCIDs"
  type        = list(string)
  default     = []
}

# ===========================================
# CONTAINER CONFIGURATION
# ===========================================

variable "container_shape" {
  description = "The shape of the container instance (e.g., CI.Standard.E4.Flex, CI.Standard.E3.Flex)"
  type        = string
  default     = "CI.Standard.E4.Flex"
}

variable "container_ocpus" {
  description = "Number of OCPUs for the container instance"
  type        = number
  default     = 1
}

variable "container_memory_in_gbs" {
  description = "Amount of memory in GBs for the container instance"
  type        = number
  default     = 4
}

variable "tf2_image" {
  description = "Docker image for the TF2 server"
  type        = string
  default     = "cm2network/tf2"
}

variable "tf2_image_tag" {
  description = "Tag of the Docker image for the TF2 server"
  type        = string
  default     = "latest"
}

# ===========================================
# TF2 SERVER CONFIGURATION
# ===========================================

variable "srcds_token" {
  description = "Steam Game Server Login Token (GSLT) - required for server to be listed on master servers"
  type        = string
  sensitive   = true
  default     = ""
}

variable "sv_setsteamaccount" {
  description = "Steam Game Server Account Token (typically same as SRCDS_TOKEN)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "server_hostname" {
  description = "Hostname displayed in the server browser"
  type        = string
  default     = "Team Fortress 2 Server"
}

variable "server_password" {
  description = "Password to join the server (empty for public server)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "rcon_password" {
  description = "RCON password for remote administration"
  type        = string
  sensitive   = true
  default     = ""
}

variable "map" {
  description = "Starting map for the server"
  type        = string
  default     = "cp_badlands"
}

variable "maxplayers" {
  description = "Maximum number of players"
  type        = number
  default     = 24

  validation {
    condition     = var.maxplayers >= 2 && var.maxplayers <= 32
    error_message = "maxplayers must be between 2 and 32"
  }
}

variable "enable_sourcemod" {
  description = "Whether to enable SourceMod (requires MetaMod)"
  type        = bool
  default     = false
}

variable "additional_env_vars" {
  description = "Additional environment variables to pass to the container"
  type        = map(string)
  default     = {}
}

# ===========================================
# DOCKER REGISTRY CONFIGURATION
# ===========================================

variable "image_pull_secrets" {
  description = "OCID of the vault secret containing Docker registry credentials (for private images)"
  type        = string
  default     = ""
}

# ===========================================
# TAGGING
# ===========================================

variable "freeform_tags" {
  description = "Freeform tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags to apply to all resources"
  type        = map(string)
  default     = {}
}
