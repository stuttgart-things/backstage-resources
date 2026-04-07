terraform {
  backend "kubernetes" {
    secret_suffix = "${{ values.backendSecretSuffix }}"
    namespace     = "${{ values.backendNamespace }}"
    config_path   = "${{ values.kubeconfigPath }}"
  }
}
