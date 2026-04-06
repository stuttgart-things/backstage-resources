# Vault Cert Issuer - ${{ values.clusterName }}

Configures a cert-manager `ClusterIssuer` (`vault-pki`) on the ${{ values.clusterName }} cluster using the [vault-base-setup](https://github.com/stuttgart-things/vault-base-setup) Terraform module. The PKI CA is hosted on a remote Vault instance.

## Prerequisites

- cert-manager deployed on the cluster (via Flux `cert-manager-install` Kustomization)
- Vault PKI CA running on a remote cluster (set up via `vault-ca`)
- `KUBECONFIG` pointing to the ${{ values.clusterName }} cluster

## Structure

```
vault-cert-issuer/
├── backend.tf                  # Terraform backend (K8s secret in ${{ values.backendNamespace }} namespace)
├── vault.tf                    # Module call (ClusterIssuer + CA secret)
├── variables.tf                # Variable declarations
├── terraform.tfvars.sops.json  # Secret values (SOPS encrypted)
└── README.md
```

## What it creates

**On Kubernetes (${{ values.clusterName }}):**
- Secret `vault-pki-ca` in `cert-manager` namespace (PKI root CA cert from remote Vault)
- Vault token secret for cert-manager
- ClusterIssuer `vault-pki` backed by remote Vault PKI

## terraform.tfvars.json

The `terraform.tfvars.json` file is gitignored and contains Vault connection secrets. Use SOPS to encrypt/decrypt it.

### Create (first time)

```bash
export VAULT_ADDR=${{ values.vaultAddr }}
export VAULT_SKIP_VERIFY=true
export VAULT_TOKEN=$(kubectl get secret vault-root-token -n vault --kubeconfig=<infra-kubeconfig> -o jsonpath='{.data.root_token}' | base64 -d)

cat <<EOF > terraform.tfvars.json
{
  "VAULT_TOKEN": "${VAULT_TOKEN}",
  "VAULT_SKIP_VERIFY": true,
  "VAULT_ADDR": "${VAULT_ADDR}"
}
EOF
```

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

## Usage

```bash
# GET VAULT CA BUNDLE FROM REMOTE VAULT
export VAULT_ADDR=${{ values.vaultAddr }}
export VAULT_SKIP_VERIFY=true
export VAULT_TOKEN=$(kubectl get secret vault-root-token -n vault --kubeconfig=<infra-kubeconfig> -o jsonpath='{.data.root_token}' | base64 -d)
export TF_VAR_vault_ca_bundle=$(curl -sk "$VAULT_ADDR/v1/pki/ca/pem" | base64 -w0)
```

```bash
# VIA DAGGER
dagger call -m github.com/stuttgart-things/blueprints/configuration@v1.79.0 terraform-apply \
  --sops-age-key env:SOPS_AGE_KEY \
  --encrypted-files "terraform.tfvars.sops.json" \
  --terraform-dir=<path-to-vault-cert-issuer> \
  --kube-config file://${{ values.kubeconfigPath }} \
  --kube-config-path "${{ values.kubeconfigPath }}" \
  --progress plain -vvvv
```

```bash
# MANUAL
export KUBECONFIG=${{ values.kubeconfigPath }}

cd vault-cert-issuer
terraform init -upgrade
terraform plan
terraform apply
cd ..
```

## Verify

```bash
kubectl get clusterissuer
kubectl get secret vault-pki-ca -n cert-manager
```

## State

Terraform state is stored in-cluster as a Kubernetes secret (`tfstate-default-${{ values.backendSecretSuffix }}`) in the `${{ values.backendNamespace }}` namespace.
