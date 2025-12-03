output "vault_id" {
  description = "The OCID of the vault"
  value       = oci_kms_vault.docker_registry_vault.id
}

output "key_id" {
  description = "The OCID of the master encryption key"
  value       = oci_kms_key.docker_registry_key.id
}

output "secret_id" {
  description = "The OCID of the Docker Hub credentials secret"
  value       = oci_vault_secret.docker_hub_credentials.id
}
