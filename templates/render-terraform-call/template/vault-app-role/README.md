# Vault AppRole - ${{ values.clusterName }}

Terraform configuration for Vault AppRole authentication on cluster `${{ values.clusterName }}`.

## What this deploys

- **AppRole Auth**: Vault AppRole authentication method with configurable roles
- **KV v2 Secrets**: Optional KV secret engine mounts
- **KV Policies**: Optional access policies for KV secrets

## Usage

```bash
terraform init -upgrade
terraform plan
terraform apply
```

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `vault_addr` | Vault server address | `${{ values.vaultAddr }}` |
| `kubeconfig_path` | Path to kubeconfig | `${{ values.kubeconfigPath }}` |
| `cluster_name` | Cluster name | `${{ values.clusterName }}` |
| `approle_roles` | AppRole definitions | `[]` |
| `secret_engines` | KV v2 secret engines | `[]` |
| `kv_policies` | KV access policies | `[]` |

## Outputs

| Output | Description |
|--------|-------------|
| `approle_role_ids` | AppRole role IDs |
| `approle_secret_ids` | AppRole secret IDs (sensitive) |

---
*Generated via Backstage render-terraform-call template*
