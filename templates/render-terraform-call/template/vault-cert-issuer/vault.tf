module "vault-base-setup" {
  source          = "github.com/stuttgart-things/vault-base-setup?ref=v1.0.0"
  vault_addr      = var.vault_addr
  skip_tls_verify = true
  kubeconfig_path = var.kubeconfig_path
  cluster_name    = var.cluster_name

  csi_enabled = false
  vso_enabled = false

  pki_enabled = false

  certmanager_vault_issuer_enabled     = true
  certmanager_vault_issuer_pki_role    = "${{ values.pkiRoleName }}"
  certmanager_vault_issuer_server      = var.vault_addr
  certmanager_vault_issuer_ca_bundle   = var.vault_ca_bundle
  certmanager_vault_issuer_policy_name = "pki-issue"
}

resource "kubernetes_secret_v1" "vault_pki_ca" {
  provider = kubernetes

  metadata {
    name      = "vault-pki-ca"
    namespace = "cert-manager"
  }

  data = {
    "ca.crt" = base64decode(var.vault_ca_bundle)
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}
