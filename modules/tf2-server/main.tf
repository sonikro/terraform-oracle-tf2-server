# ===========================================
# LOCAL VALUES
# ===========================================

locals {
  # Base environment variables for TF2 server (matching melkortf/tf2-base image)
  base_env_vars = {
    IP              = var.ip
    PORT            = tostring(var.port)
    CLIENT_PORT     = tostring(var.client_port)
    STEAM_PORT      = tostring(var.steam_port)
    STV_PORT        = tostring(var.stv_port)
    SERVER_TOKEN    = var.server_token
    RCON_PASSWORD   = var.rcon_password
    SERVER_HOSTNAME = var.server_hostname
    SERVER_PASSWORD = var.server_password
    STV_NAME        = var.stv_name
    STV_TITLE       = var.stv_title
    STV_PASSWORD    = var.stv_password
    DOWNLOAD_URL    = var.download_url
    ENABLE_FAKE_IP  = tostring(var.enable_fake_ip)
    DEMOS_TF_APIKEY = var.demos_tf_apikey
    LOGS_TF_APIKEY  = var.logs_tf_apikey
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
      registry_endpoint = var.registry_endpoint
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

data "oci_core_vnic" "tf2_vnic" {
  vnic_id = oci_container_instances_container_instance.tf2_server.vnics[0].vnic_id
}
