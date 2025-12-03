variable "compartment_id" {
  description = "The OCID of the compartment"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource naming (e.g., 'tf2-servers')"
  type        = string
  default     = "tf2-servers"
}

variable "vcn_cidr_block" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_domain" {
  description = "The availability domain for the subnet (optional - uses first AD if not specified)"
  type        = string
  default     = ""
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
