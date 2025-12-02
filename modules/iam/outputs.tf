output "dynamic_group_id" {
  description = "The OCID of the dynamic group for container instances"
  value       = oci_identity_dynamic_group.container_instances.id
}

output "dynamic_group_name" {
  description = "The name of the dynamic group for container instances"
  value       = oci_identity_dynamic_group.container_instances.name
}

output "vault_policy_id" {
  description = "The OCID of the vault policy"
  value       = oci_identity_policy.container_instances_vault_policy.id
}
