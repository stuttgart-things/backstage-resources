module "vault-base-setup" {
  source          = "github.com/stuttgart-things/vault-base-setup?ref=v1.0.0"
  vault_addr      = var.vault_addr
  skip_tls_verify = true
  kubeconfig_path = var.kubeconfig_path
  cluster_name    = var.cluster_name

  csi_enabled = false
  vso_enabled = false

  pki_enabled                      = false
  certmanager_vault_issuer_enabled = false

  # AppRole auth
  enableApproleAuth = true
  approle_roles     = var.approle_roles

  # KV v2 secrets
  secret_engines = var.secret_engines
  kv_policies    = var.kv_policies
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}
