output "pki_ca_cert" {
  description = "Root CA certificate"
  value       = module.vault-base-setup.pki_ca_cert
  sensitive   = true
}

output "approle_role_ids" {
  description = "AppRole Role IDs"
  value       = module.vault-base-setup.role_id
}

output "approle_secret_ids" {
  description = "AppRole Secret IDs"
  value       = module.vault-base-setup.secret_id
  sensitive   = true
}
