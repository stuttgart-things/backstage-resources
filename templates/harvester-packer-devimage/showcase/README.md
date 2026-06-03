# Showcase deck

A [Slidev](https://sli.dev/) deck for the *"From Click to Bootable VM"* showcase.

## Run it

```bash
cd templates/harvester-packer-devimage/showcase
npm install
npm run dev        # opens http://localhost:3030
```

Or without installing anything:

```bash
npx @slidev/cli slides.md --open
```

## Export

```bash
npm run export     # slides.pdf  (needs playwright-chromium)
npm run build      # static site in dist/
```

> Presenter notes and the full step-by-step runbook live in the
> [template README](../README.md#demo-runbook-live-showcase).
