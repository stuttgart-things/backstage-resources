# stuttgart-things/backstage-resources

<div align="center">
  <p>
    <img src="https://github.com/stuttgart-things/docs/blob/main/hugo/sthings-backstage.jpg" alt="sthings" width="450" />
  </p>
  <p>
    <strong>[An Internal Developer Portal]</strong> - built on Backstage for stuttgart-things.
  </p>
</div>

## About

This repository contains the configuration resources for the stuttgart-things Backstage Internal Developer Portal. It provides catalog entities, software templates, and deployment configurations that power the developer experience.

## Repository Structure

| Directory | Description | Contents |
|-----------|-------------|----------|
| `instances/` | Deployment configurations | SOPS-encrypted Helmfile values |
| `org/` | Organization structure | Users, Groups, Teams |
| `services/` | Service catalog | Location references to external repos |
| `templates/` | Software templates | Scaffolding for new projects |

## Components

<details>
<summary><b>Organization</b> - Users & Groups</summary>

### Organization (`org/`)

Defines the organizational structure for Backstage catalog.

#### Users

| User | Member Of |
|------|-----------|
| `guest` | guests |
| `patrick-hermann-sva` | guests |
| `sina-schlatter` | guests |

#### Groups

| Group | Type | Description |
|-------|------|-------------|
| `guests` | team | Default group for all users |
| `platform-team` | team | Platform Engineering Team |

</details>

<details>
<summary><b>Service Catalog</b> - Registered Services</summary>

### Service Catalog (`services/`)

Contains catalog location references that register external services.

#### Services

| Service | Repository | Description |
|---------|------------|-------------|
| claim-machinery-api | [GitHub](https://github.com/stuttgart-things/claim-machinery-api) | Crossplane claim rendering API |
| sthings-backstage | [GitHub](https://github.com/stuttgart-things/sthings-backstage) | Backstage application |
| blueprints | [GitHub](https://github.com/stuttgart-things/blueprints) | Infrastructure blueprints |

#### Template Locations

| Location | Description |
|----------|-------------|
| claim-machinery-templates | Claim Machinery software templates |
| terraform-dagger-templates | Terraform and Dagger software templates |

</details>

<details>
<summary><b>Software Templates</b> - Project Scaffolding</summary>

### Software Templates (`templates/`)

#### Available Templates

| Template | Tags | Owner | Description |
|----------|------|-------|-------------|
| **claim-to-pull-request** | `crossplane`, `kubernetes`, `infrastructure`, `gitops`, `claims` | platform-team | Create Crossplane resource claims via GitHub Pull Requests |
| **golang-service** | `golang`, `service`, `recommended` | platform-team | Scaffold new Go services with GitHub repository and CI/CD |

#### claim-to-pull-request

Creates a GitHub Pull Request with a rendered Crossplane claim manifest.

| Parameter | Required | Description |
|-----------|----------|-------------|
| `claimTemplate` | Yes | Claim Machinery template to render |
| `claimName` | Yes | Name for the claim resource |
| `repoUrl` | Yes | Target GitHub repository |
| `targetPath` | Yes | Path where manifest will be stored |

#### golang-service

Scaffolds a complete Go service with repository setup.

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `name` | Yes | - | Service name (lowercase, hyphens) |
| `description` | Yes | - | Brief description |
| `owner` | Yes | - | Owning group |
| `repoUrl` | Yes | github.com?owner=stuttgart-things | Repository location |
| `visibility` | No | public | Repository visibility |
| `goVersion` | No | 1.24 | Go version (1.22, 1.23, 1.24) |

</details>

<details>
<summary><b>Instance Configuration</b> - Deployment</summary>

### Instance Configuration (`instances/`)

SOPS-encrypted Helmfile configurations for deploying Backstage instances.

| Instance | File | Description |
|----------|------|-------------|
| dev | `dev.enc.yaml` | Development environment configuration |

</details>

## Usage

<details>
<summary><b>Task Runner</b></summary>

```bash
# List available tasks
task --list

# Interactive task selection
task do
```

| Task | Description |
|------|-------------|
| `do` | Interactive task selector using gum |
| `git:*` | Git-related tasks (imported) |
| `lint:*` | Linting tasks (imported) |

</details>

<details>
<summary><b>Secrets Management</b></summary>

```bash
# Decrypt configuration
sops --decrypt instances/dev.enc.yaml > instances/dev.yaml

# Deploy with Helmfile
helmfile apply -f instances/dev.yaml

# Encrypt after changes
sops --encrypt instances/dev.yaml > instances/dev.enc.yaml
```

| Command | Description |
|---------|-------------|
| `sops --decrypt` | Decrypt SOPS-encrypted file |
| `sops --encrypt` | Encrypt file with SOPS |
| `helmfile apply` | Deploy using Helmfile |

</details>

## License

See [LICENSE](LICENSE) for details.
