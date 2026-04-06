output "pki_ca_cert" {
  description = "Root CA certificate"
  value       = module.vault-base-setup.pki_ca_cert
  sensitive   = true
}
