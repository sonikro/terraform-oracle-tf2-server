# ===========================================
# DYNAMIC GROUP FOR CONTAINER INSTANCES
# ===========================================

resource "oci_identity_dynamic_group" "container_instances" {
  compartment_id = var.compartment_id
  name           = "${var.name_prefix}-container-instances-dynamic-group"
  description    = "Dynamic group for all TF2 container instances"
  matching_rule  = "ALL {resource.type = 'containerinstance'}"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

# ===========================================
# POLICY: CONTAINER INSTANCES VAULT ACCESS
# ===========================================

resource "oci_identity_policy" "container_instances_vault_policy" {
  compartment_id = var.compartment_id
  name           = "${var.name_prefix}-container-instances-vault-policy"
  description    = "Allow container instances to read vault secret bundles for Docker image pull authorization"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.container_instances.name} to read secret-bundles in compartment id ${var.compartment_id}"
  ]
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}
