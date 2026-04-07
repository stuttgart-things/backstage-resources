output "approle_role_ids" {
  description = "AppRole role IDs"
  value       = module.vault-base-setup.role_id
}

output "approle_secret_ids" {
  description = "AppRole secret IDs"
  value       = module.vault-base-setup.secret_id
  sensitive   = true
}
