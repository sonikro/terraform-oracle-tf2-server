variable "compartment_id" {
  description = "The OCID of the compartment (must be tenancy root for IAM policies)"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
  default     = "tf2-servers"
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
