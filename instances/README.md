# BACKSTAGE INSTANCES

## Directory Structure

```
instances/
  helmfile/    # Legacy helmfile-based deployments (encrypted values)
  flux/        # Flux GitOps deployments
```

---

## Deploying with Flux (GitOps)

The Flux app template lives in the [flux repo](https://github.com/stuttgart-things/flux) at `apps/backstage/`.

Files in `flux/`:

| File | Description |
|------|-------------|
| `flux-backstage-kustomization.yaml` | Flux Kustomization with postBuild variables |
| `backstage-secrets.enc.yaml` | SOPS-encrypted Secret for sensitive values |
| `backstage-catalog-config.yaml` | ConfigMap with catalog locations |
| `backstage-helm-overrides.yaml` | ConfigMap for image tag (string-safe) |

### 1. Create the SOPS-encrypted secret

Fill in the real values and encrypt:

```bash
cd flux/
sops --decrypt backstage-secrets.enc.yaml > backstage-secrets.yaml
vi backstage-secrets.yaml
sops --encrypt backstage-secrets.yaml > backstage-secrets.enc.yaml
rm backstage-secrets.yaml
```

Apply to the cluster:

```bash
sops --decrypt backstage-secrets.enc.yaml | kubectl apply -f -
```

### 2. Create the catalog ConfigMap

Edit `backstage-catalog-config.yaml` with your catalog locations (add as many as needed), then apply:

```bash
kubectl apply -f backstage-catalog-config.yaml
```

### 3. Create the helm overrides ConfigMap

Edit `backstage-helm-overrides.yaml` with the image tag, then apply:

```bash
kubectl apply -f backstage-helm-overrides.yaml
```

### 4. Adjust the Flux Kustomization

Edit `flux-backstage-kustomization.yaml` and update `postBuild.substitute` values for your cluster:

| Variable | Description | Example |
|----------|-------------|---------|
| `DOMAIN` | Cluster FQDN | `movie-scripts2.sthings-vsphere.labul.sva.de` |
| `GATEWAY_NAME` | Gateway resource name (`kubectl get gateways -A`) | `movie-scripts2-gateway` |
| `GATEWAY_NAMESPACE` | Gateway namespace | `default` |
| `BACKSTAGE_STORAGE_CLASS` | Storage class (`kubectl get sc`) | `nfs4-csi` |

### 5. Apply the Flux Kustomization

```bash
kubectl apply -f flux-backstage-kustomization.yaml
```

### 6. Verify

```bash
kubectl get kustomizations -n flux-system backstage
kubectl get helmreleases -n portal
kubectl get pods -n portal
```

---

## Deploying with Helmfile (Legacy)

Encrypted helmfile values are in `helmfile/`.

### 1. Decrypt and deploy

```bash
export KUBECONFIG=~/.kube/<cluster-name>
sops --decrypt helmfile/<instance>.enc.yaml > <instance>.yaml
helmfile apply -f <instance>.yaml
rm <instance>.yaml
```

### 2. Configure GitHub OAuth App

Go to **GitHub > Settings > Developer settings > OAuth Apps** and create/update an OAuth app:

- **Homepage URL:** `https://backstage.<clusterDomain>`
- **Authorization callback URL:** `https://backstage.<clusterDomain>/api/auth/github/handler/frame`
