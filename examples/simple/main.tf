# ===========================================
# EXAMPLE: MULTIPLE TF2 SERVERS
# ===========================================
# This example demonstrates how to deploy multiple
# TF2 servers sharing the same network infrastructure
# using the for_each approach.

terraform {
  required_version = ">= 1.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0"
    }
  }
}

# ===========================================
# PROVIDER CONFIGURATION
# ===========================================

provider "oci" {
  # Configure your OCI provider settings
  # region              = "us-chicago-1"
  # config_file_profile = "us-chicago-1"
}

# ===========================================
# SHARED INFRASTRUCTURE
# ===========================================

# Create shared network infrastructure (VCN, subnet, NSG)
module "network" {
  source = "../../modules/network"

  compartment_id = var.compartment_id
  name_prefix    = "tf2-servers"

  # Optional: customize network settings
  vcn_cidr_block    = "10.0.0.0/16"
  subnet_cidr_block = "10.0.1.0/24"

  freeform_tags = var.freeform_tags
}

# Create IAM policies for container instances
# Note: This should only be created once per tenancy/compartment
module "iam" {
  source = "../../modules/iam"

  compartment_id = var.compartment_id
  name_prefix    = "tf2-servers"

  freeform_tags = var.freeform_tags
}

# Optional: Create vault for Docker Hub credentials (if using private images)
# module "vault" {
#   source = "../../modules/vault"
#
#   compartment_id  = var.compartment_id
#   name_prefix     = "tf2-servers"
#   docker_username = var.docker_username
#   docker_password = var.docker_password
#
#   freeform_tags = var.freeform_tags
# }

# ===========================================
# SERVER CONFIGURATIONS
# ===========================================

locals {
  servers = {
    base = {
      server_hostname = "Standard Server"
      image           = "ghcr.io/melkortf/tf2-base"
    }
    competitive = {
      server_hostname = "Competitive Server"
      image           = "ghcr.io/melkortf/tf2-competitive"
    }
  }
}

# ===========================================
# TF2 SERVERS (using for_each)
# ===========================================

module "tf2_servers" {
  source   = "../../modules/tf2-server"
  for_each = local.servers

  compartment_id      = var.compartment_id
  server_name         = "tf2-${each.key}-server"
  availability_domain = module.network.availability_domain
  subnet_id           = module.network.subnet_id
  nsg_ids             = [module.network.nsg_id]
  tf2_image           = each.value.image

  # Container configuration
  container_shape         = "CI.Standard.E4.Flex"
  container_ocpus         = 1
  container_memory_in_gbs = 4

  # TF2 server configuration
  server_token    = var.server_token
  server_hostname = each.value.server_hostname
  rcon_password   = var.rcon_password

  freeform_tags = var.freeform_tags

  depends_on = [module.iam]
}
