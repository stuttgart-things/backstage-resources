variable "vault_addr" {
  type        = string
  description = "Vault server address"
  default     = "${{ values.vaultAddr }}"
}

variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig"
  default     = "${{ values.kubeconfigPath }}"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name"
  default     = "${{ values.clusterName }}"
}

variable "pki_common_name" {
  type        = string
  description = "PKI root CA common name / allowed domain"
  default     = "${{ values.pkiCommonName }}"
}

variable "approle_roles" {
  type = list(object({
    name           = string
    token_policies = list(string)
  }))
  description = "AppRole definitions for Vault"
  default     = []
}

variable "secret_engines" {
  type = list(object({
    name        = string
    path        = string
    description = string
    data_json   = string
  }))
  description = "KV v2 secret engine mounts with initial data"
  default     = []
}

variable "kv_policies" {
  type = list(object({
    name         = string
    capabilities = string
  }))
  description = "KV access policies"
  default     = []
}
