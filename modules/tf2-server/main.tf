# ===========================================
# LOCAL VALUES
# ===========================================

locals {
  # Base environment variables for TF2 server
  base_env_vars = {
    SRCDS_TOKEN        = var.srcds_token
    SV_SETSTEAMACCOUNT = var.sv_setsteamaccount != "" ? var.sv_setsteamaccount : var.srcds_token
    SRCDS_HOSTNAME     = var.server_hostname
    SRCDS_PW           = var.server_password
    SRCDS_RCONPW       = var.rcon_password
    SRCDS_STARTMAP     = var.map
    SRCDS_MAXPLAYERS   = tostring(var.maxplayers)
  }

  # Merge all environment variables
  all_env_vars = merge(
    local.base_env_vars,
    var.additional_env_vars
  )
}

# ===========================================
# CONTAINER INSTANCE
# ===========================================

resource "oci_container_instances_container_instance" "tf2_server" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  display_name        = var.server_name

  shape = var.container_shape

  shape_config {
    ocpus         = var.container_ocpus
    memory_in_gbs = var.container_memory_in_gbs
  }

  containers {
    display_name          = "${var.server_name}-container"
    image_url             = "${var.tf2_image}:${var.tf2_image_tag}"
    environment_variables = local.all_env_vars
  }

  vnics {
    subnet_id             = var.subnet_id
    nsg_ids               = var.nsg_ids
    is_public_ip_assigned = true
    display_name          = "${var.server_name}-vnic"
  }

  # Image pull secrets configuration (for private Docker registries)
  dynamic "image_pull_secrets" {
    for_each = var.image_pull_secrets != "" ? [1] : []
    content {
      registry_endpoint = "https://index.docker.io/v1/"
      secret_type       = "VAULT"
      secret_id         = var.image_pull_secrets
    }
  }

  # Graceful shutdown timeout
  graceful_shutdown_timeout_in_seconds = 30

  # Container restart policy - always restart to keep the server running
  container_restart_policy = "ALWAYS"

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# ===========================================
# DATA SOURCE FOR PUBLIC IP
# ===========================================

data "oci_core_vnic_attachments" "tf2_vnic_attachments" {
  compartment_id = var.compartment_id

  instance_id = oci_container_instances_container_instance.tf2_server.id
}

data "oci_core_vnic" "tf2_vnic" {
  vnic_id = data.oci_core_vnic_attachments.tf2_vnic_attachments.vnic_attachments[0].vnic_id
}
