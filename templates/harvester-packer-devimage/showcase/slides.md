---
theme: default
title: From Click to Bootable VM
info: |
  ## From Click to Bootable VM
  Self-Service Golden Images with Backstage, Packer & Harvester.
  stuttgart-things platform showcase.
class: text-center
transition: slide-left
mdc: true
---

# From Click to Bootable VM

### Self-Service Golden Images with **Backstage · Packer · Harvester**

<div class="pt-8 opacity-70">
A platform-engineering showcase — stuttgart-things
</div>

<div class="abs-br m-6 text-sm opacity-50">
Press <kbd>Space</kbd> to start
</div>

---
layout: statement
---

# The problem

Developers wait **days** for a VM image with the right users and tools.

Platform teams hand-roll Packer configs, SSH into runners, and copy images around by hand.

<div class="pt-6 text-2xl opacity-80">
There is no <span class="text-teal-400">golden path</span>.
</div>

---
layout: default
---

# The idea: a self-service golden path

<v-clicks>

- A developer opens **one form** in Backstage
- Picks a base image, adds their **users** and **packages**
- Everything else is **GitOps + CI** — no tickets, no SSH, no manual Packer

</v-clicks>

<div v-click class="mt-8 p-4 rounded border border-teal-500/40 bg-teal-500/10">
Form → Pull Request → Packer build → image in Harvester → entry in the catalog.
</div>

---
layout: default
---

# How it flows

```mermaid {scale: 0.62}
flowchart LR
    A[Backstage form] --> B[Resolve target name]
    B --> C[Fetch existing<br/>packages + users]
    C --> D[Merge & de-dup]
    D --> E[Render config files]
    E --> F[Open PR<br/>stuttgart-things/harvester]
    F --> G[Register in catalog]
    F --> H{{packer-pr-build.yml}}
    H --> I[packer build]
    I --> J[Upload to Harvester]
    J --> K[Auto-merge PR]
```

<div class="mt-4 text-sm opacity-70">
Twelve scaffolder steps — fetch, parse, merge, render, publish, register.
</div>

---
layout: section
---

# Live demo

4 acts · ~5 minutes

---
layout: default
---

# Act 1 — Self-Service

<div grid="~ cols-2 gap-6">

<div>

In **Backstage → Create → Create Harvester VM-Template**:

<v-clicks>

- **Base image:** Ubuntu 22.04 (Jammy)
- **Add user:** name + SSH public key
- **Add packages:** `docker.io`, `kubectl`
- Review → **Catalog Resource Preview**

</v-clicks>

</div>

<div v-click class="text-sm opacity-80 pt-4">

> "Existing users and packages are preserved.
> I'm just adding myself and two tools — and they get
> **de-duplicated** against the base list automatically."

</div>

</div>

---
layout: default
---

# Act 2 — GitOps

<v-clicks>

- The template opens a **Pull Request** on `stuttgart-things/harvester`
- Diff lives in `packer/ubuntu22/` — `packages.yaml` + `users.yaml`
- Branch is **namespaced per user** → no collisions

</v-clicks>

<div v-click class="mt-8 text-xl">
Nothing magic. It's all <span class="text-teal-400">Git</span> —
reviewable, auditable, revertible.
</div>

---
layout: default
---

# Act 3 — CI/CD

<v-clicks>

- The PR triggers **`packer-pr-build.yml`**
- Packer builds the image on a **KVM runner**
- Image is **uploaded to Harvester** (`upload_to_harvester: true`)
- On green → PR **auto-merges**, branch deleted

</v-clicks>

<div v-click class="mt-8 p-4 rounded border border-amber-500/40 bg-amber-500/10 text-sm">
The human approved a form. The machine did the build, the upload, and the merge.
</div>

---
layout: default
---

# Act 4 — Discoverability

<div grid="~ cols-2 gap-6">

<div>

<v-clicks>

- New **`u22-dev`** image appears in **Harvester → Images**
- Registered **Resource** in the Backstage catalog
- Boot a VM from it — done

</v-clicks>

</div>

<div v-click class="text-sm opacity-80 pt-4">

> "From a form to a bootable golden image,
> fully governed by Git.
> That's the IDP promise made concrete."

</div>

</div>

---
layout: section
---

# Part 2 — the Admin path

Same engine, different governance: **hardened & staged** images

---
layout: default
---

# Two golden paths, one engine

| | 🧑‍💻 Dev template | 🛡️ Admin template |
|---|---|---|
| **Audience** | Developers | Platform admins |
| **Purpose** | Quick test VMs | Hardened, prod-bound images |
| **Hardening** | none | CIS Level 1 / 2 + tooling |
| **Stages** | `u26-dev` | `u26-staging` → `u26-prod` |
| **PR flow** | auto-merge on green | **draft PR, 4-eyes review** |

<div v-click class="mt-6 text-lg opacity-80">
Self-service speed for devs · governed promotion for admins.
</div>

---
layout: default
---

# Admin — Hardening

In **Create Hardened Harvester VM-Template (Admin)**:

<v-clicks>

- Pick a **CIS profile** — Level 1 (baseline) or Level 2 (defense-in-depth)
- Choose **security tooling** — `auditd`, `aide`, `fail2ban`, `unattended-upgrades`…
- It's merged into the base package list and written to **`hardening.yaml`**

</v-clicks>

<div v-click class="mt-6 p-4 rounded border border-teal-500/40 bg-teal-500/10 text-sm">
The Packer build reads <code>hardening.yaml</code> and applies the CIS benchmark — compliance as config, in Git.
</div>

---
layout: default
---

# Admin — Staging & promotion

```mermaid {scale: 0.7}
flowchart LR
    A[Stage: Staging] --> B[Build u26-staging]
    B --> C[Validate<br/>boot + compliance scan]
    C --> D[Re-run · Stage: Production]
    D --> E[Build u26-prod]
    E --> F[Promoted ✅]
```

<v-clicks>

- Staging first — build and **validate** `u26-staging`
- Same inputs, **Production** stage → `u26-prod`
- The draft-PR diff is your **parity check** before promoting

</v-clicks>

---
layout: default
---

# Admin — Review-gated

<v-clicks>

- The admin template opens a **draft Pull Request** — never auto-merged
- A second admin **reviews** the hardening config and merges
- Production is a **deliberate human gate**, not an accident

</v-clicks>

<div v-click class="mt-8 text-xl">
Devs get <span class="text-teal-400">speed</span>.
Admins get <span class="text-amber-400">control</span>.
Same GitOps engine.
</div>

---
layout: default
---

# What we hardened for this showcase

<v-clicks>

- 🧹 **Package de-dup** — `$distinct` merge, no duplicate entries
- 👥 **User update semantics** — re-submitting a name updates, not duplicates
- 🌿 **Concurrency-safe branches** — per-user PR branch names
- 🟠 **Ubuntu 26.04 LTS** — replaced the obsolete interim release
- 🛡️ **Admin template** — CIS hardening, staging→prod promotion, 4-eyes review
- 📋 **Demo runbook + pre-flight checklist** — clean data, warm runner, green path

</v-clicks>

---
layout: statement
---

# Takeaway

A **form** on one end. A **bootable, catalogued image** on the other.

Everything between is **Git and CI** — governed, repeatable, self-service.

<div class="pt-4 text-lg opacity-80">
One engine, two paths: <span class="text-teal-400">speed</span> for devs · <span class="text-amber-400">control</span> for admins.
</div>

<div class="pt-8 opacity-60 text-base">
Backstage · Packer · Harvester — stuttgart-things
</div>

---
layout: center
class: text-center
---

# Thank you

Questions?

<div class="pt-6 text-sm opacity-60">
Template: <code>backstage-resources/templates/harvester-packer-devimage</code>
</div>
