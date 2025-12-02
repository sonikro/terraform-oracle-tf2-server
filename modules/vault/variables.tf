variable "compartment_id" {
  description = "The OCID of the compartment"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
  default     = "tf2-servers"
}

variable "docker_username" {
  description = "Docker Hub username for pulling container images"
  type        = string
  sensitive   = true
}

variable "docker_password" {
  description = "Docker Hub password or access token for pulling container images"
  type        = string
  sensitive   = true
}

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
