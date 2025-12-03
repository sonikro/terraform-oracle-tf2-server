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
  default     = "ghcr.io/melkortf/tf2-base"
}

variable "tf2_image_tag" {
  description = "Tag of the Docker image for the TF2 server"
  type        = string
  default     = "latest"
}

# ===========================================
# TF2 SERVER CONFIGURATION
# ===========================================

variable "server_token" {
  description = "Steam Game Server Login Token (GSLT) - required for server to be listed on master servers"
  type        = string
  sensitive   = true
  default     = ""
}

variable "server_hostname" {
  description = "Hostname displayed in the server browser"
  type        = string
  default     = "A Team Fortress 2 server"
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
}

variable "port" {
  description = "The port which the server will run on"
  type        = number
  default     = 27015
}

variable "client_port" {
  description = "The client port"
  type        = number
  default     = 27016
}

variable "steam_port" {
  description = "Master server updater port"
  type        = number
  default     = 27018
}

variable "stv_port" {
  description = "SourceTV port"
  type        = number
  default     = 27020
}

variable "stv_name" {
  description = "SourceTV host name"
  type        = string
  default     = "Source TV"
}

variable "stv_title" {
  description = "Title for the SourceTV spectator UI"
  type        = string
  default     = "A Team Fortress 2 server Source TV"
}

variable "stv_password" {
  description = "SourceTV password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "download_url" {
  description = "Download URL for the FastDL"
  type        = string
  default     = "https://fastdl.serveme.tf/"
}

variable "enable_fake_ip" {
  description = "Enables/Disables SDR by turning the -enablefakeip flag on or off"
  type        = number
  default     = 0

  validation {
    condition     = var.enable_fake_ip == 0 || var.enable_fake_ip == 1
    error_message = "enable_fake_ip must be 0 or 1"
  }
}

variable "ip" {
  description = "Specifies the address to use for the bind(2) syscall"
  type        = string
  default     = "0.0.0.0"
}

variable "demos_tf_apikey" {
  description = "The API key used to upload the demo to demos.tf"
  type        = string
  sensitive   = true
  default     = ""
}

variable "logs_tf_apikey" {
  description = "The API key used to upload logs to logs.tf"
  type        = string
  sensitive   = true
  default     = ""
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

variable "registry_endpoint" {
  description = "Docker registry endpoint URL (e.g., https://index.docker.io/v1/ for Docker Hub, https://ghcr.io for GitHub Container Registry)"
  type        = string
  default     = "https://ghcr.io"
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
