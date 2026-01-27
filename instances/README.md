# BACKSTAGE INSTANCES

```bash
sops --encrypt dev.yaml > dev.enc.yaml
sops --decrypt dev.enc.yaml > dev.yaml
helmfile apply -f dev.yaml
```


<!--

```bash
#ENCRYPT FILE w/ SOPS
dagger call -m github.com/stuttgart-things/dagger/sops encrypt \
--plaintext-file ./dev.yaml \
--file-extension=yaml \
--age-key env:AGE_PUB \
--sops-config=/home/sthings/.sops.yaml \
export --path=./secrets.enc.yaml
```

```bash
#ENCRYPT FILE w/ SOPS
dagger call -m github.com/stuttgart-things/dagger/sops encrypt \
--plaintext-file ./dev.yaml \
--file-extension=yaml \
--age-key env:AGE_PUB \
--sops-config=/home/sthings/.sops.yaml \
export --path=./secrets.enc.yaml
```

```bash
# DecryptSops
dagger call -m github.com/stuttgart-things/dagger/sops decrypt \
--encryptedFile=./secrets.enc.yaml \
--sops-key env:SOPS_AGE_KEY -->
