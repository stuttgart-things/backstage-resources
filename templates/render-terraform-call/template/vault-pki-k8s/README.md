# Vault Setup - ${{ values.clusterName }}

Configures the Vault PKI secrets engine, AppRole auth, KV v2 secrets, and a cert-manager `ClusterIssuer` (`vault-pki`) on the ${{ values.clusterName }} cluster using the [vault-base-setup](https://github.com/stuttgart-things/vault-base-setup) Terraform module.

## Prerequisites

- Vault deployed and unsealed on the cluster (via Flux `vault` + `vault-autounseal` Kustomizations)
- cert-manager deployed on the cluster (via Flux `cert-manager-install` Kustomization)
- `KUBECONFIG` pointing to the ${{ values.clusterName }} cluster

## Structure

```
vault-ca/
├── backend.tf                  # Terraform backend (K8s secret in ${{ values.backendNamespace }} namespace)
├── vault.tf                    # Module call (PKI, AppRole, KV)
├── variables.tf                # Variable declarations
├── outputs.tf                  # Outputs (PKI CA, AppRole IDs)
├── terraform.tfvars.sops.json  # Secret values (SOPS encrypted)
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


## Usage

```bash
# VIA DAGGER
dagger call -m github.com/stuttgart-things/blueprints/configuration@v1.79.0 terraform-apply \
  --sops-age-key env:SOPS_AGE_KEY \
  --encrypted-files "terraform.tfvars.sops.json" \
  --terraform-dir=<path-to-vault-ca> \
  --kube-config file://${{ values.kubeconfigPath }} \
  --kube-config-path "${{ values.kubeconfigPath }}" \
  --export-tf-output=true file --path output.json contents \
  --progress plain -vvvv
```

```bash
# MANUAL
export KUBECONFIG=${{ values.kubeconfigPath }}
export VAULT_ADDR=${{ values.vaultAddr }}
export VAULT_SKIP_VERIFY=true
export VAULT_TOKEN=$(kubectl get secret vault-root-token -n vault -o jsonpath='{.data.root_token}' | base64 -d)

terraform init -upgrade
terraform plan
terraform apply
```

## Testing

Issue a test certificate against the `vault-pki` ClusterIssuer:

```bash
export KUBECONFIG=${{ values.kubeconfigPath }}

# Create test certificate
kubectl apply -f - <<'EOF'
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: test-vault-cert
  namespace: default
spec:
  secretName: test-vault-cert-tls
  issuerRef:
    name: vault-pki
    kind: ClusterIssuer
  commonName: test.${{ values.pkiAllowedDomain }}
  dnsNames:
    - test.${{ values.pkiAllowedDomain }}
  duration: 24h
  renewBefore: 1h
EOF

# Verify it becomes Ready
kubectl get certificate test-vault-cert -n default

# Clean up
kubectl delete certificate test-vault-cert -n default
kubectl delete secret test-vault-cert-tls -n default
```

## Install CA Certificate Locally

To trust certificates issued by the Vault PKI CA on your local machine:

```bash
export KUBECONFIG=${{ values.kubeconfigPath }}

# Extract the CA certificate
kubectl get secret vault-pki-ca -n cert-manager \
  -o jsonpath='{.data.ca\.crt}' | base64 -d > vault-pki-ca.crt

# Install (Ubuntu/Debian)
sudo cp vault-pki-ca.crt /usr/local/share/ca-certificates/vault-pki-ca.crt
sudo update-ca-certificates

# Install (RHEL/Fedora)
sudo cp vault-pki-ca.crt /etc/pki/ca-trust/source/anchors/vault-pki-ca.crt
sudo update-ca-trust

# Install (macOS)
sudo security add-trusted-cert -d -r trustRoot \
  -k /Library/Keychains/System.keychain vault-pki-ca.crt

# Verify
openssl x509 -in vault-pki-ca.crt -noout -subject -issuer
# subject=C=DE, O=sva, CN=${{ values.pkiCommonName }}
# issuer=C=DE, O=sva, CN=${{ values.pkiCommonName }}
```

## State

Terraform state is stored in-cluster as a Kubernetes secret (`tfstate-default-${{ values.backendSecretSuffix }}`) in the `${{ values.backendNamespace }}` namespace.
