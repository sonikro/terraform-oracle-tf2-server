# ===========================================
# VAULT FOR DOCKER REGISTRY CREDENTIALS
# ===========================================

resource "oci_kms_vault" "docker_registry_vault" {
  compartment_id = var.compartment_id
  display_name   = "${var.name_prefix}-docker-registry-vault"
  vault_type     = "DEFAULT"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

# ===========================================
# MASTER ENCRYPTION KEY
# ===========================================

resource "oci_kms_key" "docker_registry_key" {
  compartment_id      = var.compartment_id
  display_name        = "${var.name_prefix}-docker-registry-key"
  management_endpoint = oci_kms_vault.docker_registry_vault.management_endpoint

  key_shape {
    algorithm = "AES"
    length    = 32 # 256-bit AES encryption (32 bytes)
  }

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

# ===========================================
# SECRET WITH DOCKER HUB CREDENTIALS
# ===========================================

resource "oci_vault_secret" "docker_hub_credentials" {
  compartment_id = var.compartment_id
  vault_id       = oci_kms_vault.docker_registry_vault.id
  key_id         = oci_kms_key.docker_registry_key.id
  secret_name    = "${var.name_prefix}-docker-hub-credentials"
  description    = "Docker Hub credentials for pulling container images"

  secret_content {
    content_type = "BASE64"
    content = base64encode(jsonencode({
      username = var.docker_username
      password = var.docker_password
    }))
  }

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}
