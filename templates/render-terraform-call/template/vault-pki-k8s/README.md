# Vault Setup - ${{ values.clusterName }}

Configures the Vault PKI secrets engine, AppRole auth, KV v2 secrets, and a cert-manager `ClusterIssuer` (`vault-pki`) on the ${{ values.clusterName }} cluster using the [vault-base-setup](https://github.com/stuttgart-things/vault-base-setup) Terraform module.

## Prerequisites

- Vault deployed and unsealed on the cluster (via Flux `vault` + `vault-autounseal` Kustomizations)
- cert-manager deployed on the cluster (via Flux `cert-manager-install` Kustomization)
- `KUBECONFIG` pointing to the ${{ values.clusterName }} cluster

## Structure

```
vault/
├── backend.tf              # Terraform backend (K8s secret in ${{ values.backendNamespace }} namespace)
├── vault.tf                # Module call (PKI, AppRole, KV)
├── variables.tf            # Variable declarations
├── outputs.tf              # Outputs (PKI CA, AppRole IDs)
├── terraform.tfvars.json   # Secret values (gitignored, SOPS-encryptable)
└── README.md
```

## What it creates

**On Vault:**
- PKI secrets engine at `pki/` with Root CA (10y TTL)
- PKI role `${{ values.pkiRoleName }}` (allows `*.${{ values.pkiAllowedDomain }}`)
- Policy `pki-issue` for cert-manager token
- Vault token for cert-manager (720h TTL, renewable)
- AppRole auth backend with roles (e.g. `argocd` for AVP)
- KV v2 secrets engine at `apps/` with application secrets
- KV read policies (e.g. `read-all-apps-kvv2`)

**On Kubernetes:**
- Secret `vault-pki-token` in `cert-manager` namespace
- Secret `vault-pki-ca` in `cert-manager` namespace (PKI root CA cert)
- ClusterIssuer `vault-pki` backed by Vault PKI

## terraform.tfvars.json

The `terraform.tfvars.json` file is gitignored and contains AppRole definitions, KV secrets, and policies. Use SOPS to encrypt/decrypt it.

### Encrypt (before committing to git)

```bash
dagger call -m github.com/stuttgart-things/dagger/sops@v0.82.1 encrypt \
  --age-key env:SOPS_AGE_RECIPIENTS \
  --plaintext-file terraform.tfvars.json \
  --file-extension json \
  export --path=terraform.tfvars.sops.json
```

### Decrypt (before terraform apply)

```bash
dagger call -m github.com/stuttgart-things/dagger/sops@v0.82.1 decrypt \
  --age-key env:SOPS_AGE_KEY \
  --encrypted-file terraform.tfvars.sops.json \
  export --path=terraform.tfvars.json
```

### Example terraform.tfvars.json

```json
{
  "approle_roles": [
    {
      "name": "argocd",
      "token_policies": ["read-all-apps-kvv2", "pki-issue"]
    }
  ],
  "secret_engines": [
    {
      "path": "apps",
      "name": "test",
      "description": "Application secrets",
      "data_json": "{\"username\": \"testuser\", \"password\": \"testpassword\"}"
    }
  ],
  "kv_policies": [
    {
      "name": "read-all-apps-kvv2",
      "capabilities": "path \"apps/data/*\" {\n    capabilities = [\"read\", \"list\"]\n}\npath \"apps/metadata/*\" {\n    capabilities = [\"read\", \"list\"]\n}\n"
    }
  ]
}
```

## Usage

```bash
export KUBECONFIG=${{ values.kubeconfigPath }}
export VAULT_ADDR=${{ values.vaultAddr }}
export VAULT_SKIP_VERIFY=true
export VAULT_TOKEN=$(kubectl get secret vault-root-token -n vault -o jsonpath='{.data.root_token}' | base64 -d)

terraform init -upgrade
terraform plan
terraform apply
```

## Get AppRole Credentials

After apply, retrieve the AppRole credentials for consumer clusters (e.g. ArgoCD):

```bash
terraform output approle_role_ids
terraform output -json approle_secret_ids
```

## State

Terraform state is stored in-cluster as a Kubernetes secret (`tfstate-default-${{ values.backendSecretSuffix }}`) in the `${{ values.backendNamespace }}` namespace.
