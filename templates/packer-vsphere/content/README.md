# ${{ values.vm_template_name }}-${{ values.lab | lower }}-vsphere-${{ values.provisioning_type }}

Packer vSphere VM template build configuration.

## Details

| Parameter | Value |
|-----------|-------|
| OS | ${{ values.os_version }} (${{ values.os_codename }}) |
| Lab | ${{ values.lab }} |
| Provisioning | ${{ values.provisioning_type }} |
| CPUs | ${{ values.vm_cpus }} |
| RAM | ${{ values.vm_ram }} MB |
| Disk | ${{ values.vm_disk_size }} MB |

## Build

```bash
dagger call -m github.com/stuttgart-things/dagger/packer bake \
  --local-dir <path> \
  --build-path ${{ values.vm_template_name }}.pkr.hcl \
  --packer-version 1.13.1 \
  --vault-addr $VAULT_ADDR \
  --vault-token env:VAULT_TOKEN \
  --vault-role-id env:VAULT_ROLE_ID \
  --vault-secret-id env:VAULT_SECRET_ID \
  --progress plain -vv
```
