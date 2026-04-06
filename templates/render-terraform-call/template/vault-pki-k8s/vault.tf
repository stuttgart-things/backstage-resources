module "vault-base-setup" {
  source          = "github.com/stuttgart-things/vault-base-setup?ref=v1.0.0"
  vault_addr      = var.vault_addr
  skip_tls_verify = true
  kubeconfig_path = var.kubeconfig_path
  cluster_name    = var.cluster_name

  csi_enabled = false
  vso_enabled = false

  # AppRole auth
  enableApproleAuth = length(var.approle_roles) > 0
  approle_roles     = var.approle_roles

  # KV v2 secrets
  secret_engines = var.secret_engines
  kv_policies    = var.kv_policies

  # PKI
  pki_enabled      = true
  pki_path         = "pki"
  pki_common_name  = var.pki_common_name
  pki_organization = "sva"
  pki_country      = "DE"
  pki_key_type     = "rsa"
  pki_key_bits     = 2048
  pki_root_ttl     = "87600h"

  pki_roles = [
    {
      name             = "${{ values.pkiRoleName }}"
      allowed_domains  = ["${{ values.pkiAllowedDomain }}"]
      allow_subdomains = true
      max_ttl          = "8760h"
    }
  ]

  certmanager_vault_issuer_enabled  = true
  certmanager_vault_issuer_pki_role = "${{ values.pkiRoleName }}"
  certmanager_vault_issuer_server   = "${{ values.vaultIssuerServer }}"
}

resource "kubernetes_secret_v1" "vault_pki_ca" {
  provider = kubernetes

  metadata {
    name      = "vault-pki-ca"
    namespace = "cert-manager"
  }

  data = {
    "ca.crt" = module.vault-base-setup.pki_ca_cert
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}
