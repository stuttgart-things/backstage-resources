variable "vault_addr" {
  type        = string
  description = "Vault server address (sthings-infra)"
  default     = "${{ values.vaultAddr }}"
}

variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig (${{ values.clusterName }})"
  default     = "${{ values.kubeconfigPath }}"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name"
  default     = "${{ values.clusterName }}"
}

variable "vault_ca_bundle" {
  type        = string
  description = "Base64-encoded Vault PKI root CA certificate"
  default     = ""
}
