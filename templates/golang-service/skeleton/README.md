# ${{ values.name }}

[![Release](https://github.com/${{ values.repoOwner }}/${{ values.repoName }}/actions/workflows/release.yml/badge.svg)](https://github.com/${{ values.repoOwner }}/${{ values.repoName }}/actions/workflows/release.yml)

${{ values.description }}

## Prerequisites

- Go ${{ values.goVersion }}+
- [Task](https://taskfile.dev/) (optional, for task automation)

## Getting Started

```bash
# Clone the repository
git clone https://github.com/${{ values.repoOwner }}/${{ values.repoName }}.git
cd ${{ values.repoName }}

# Install dependencies
go mod tidy

# Run the application
go run .
# or with Task
task run
```

## Releases

- Automated releases via GitHub Actions with [semantic-release](https://github.com/semantic-release/semantic-release).
- Configuration: `.releaserc.json`, Workflow: `.github/workflows/release.yml`, Changelog: `CHANGELOG.md`.
- Branches: `main` (Stable), `release/next` (Release branch for changelog push).

### Conventional Commits

Please use the [Conventional Commits](https://www.conventionalcommits.org/) format, e.g.:
- `feat: New API for X`
- `fix: Fix memory leak`
- `chore: Update dependencies`

### Local Dry-Run (optional)

If Node.js is installed, you can test with a dry-run:

```bash
npx semantic-release --dry-run
```

## Branch Protection (recommended)

Set up branch protection in GitHub to ensure stable releases:

- **Protected branches**: `main` and `release/next`
- **Require pull request reviews before merging**: enable (at least 1 review)
- **Require status checks to pass before merging**: enable and select the `Release` workflow
- **Require linear history**: optionally enable
- **Restrict who can push to matching branches**: optional (maintainers only)
- **Dismiss stale pull request approvals when new commits are pushed**: optionally enable

Note: You can find these settings under
GitHub → Repository → Settings → Branches → Branch protection rules.

### Alternative: CLI (gh)

Branch protection can be set via the GitHub CLI (admin rights required):

```bash
# Adjust values
OWNER=${{ values.repoOwner }}
REPO=${{ values.repoName }}

# Protection for main
gh api -X PUT \
	repos/$OWNER/$REPO/branches/main/protection \
	-H "Accept: application/vnd.github+json" \
	-F required_status_checks.strict=true \
	-F required_status_checks.contexts='["Release"]' \
	-F enforce_admins=true \
	-F required_pull_request_reviews.dismiss_stale_reviews=true \
	-F required_pull_request_reviews.required_approving_review_count=1 \
	-F restrictions=null

# Protection for release/next
gh api -X PUT \
	repos/$OWNER/$REPO/branches/release/next/protection \
	-H "Accept: application/vnd.github+json" \
	-F required_status_checks.strict=true \
	-F required_status_checks.contexts='["Release"]' \
	-F enforce_admins=true \
	-F required_pull_request_reviews.dismiss_stale_reviews=true \
	-F required_pull_request_reviews.required_approving_review_count=1 \
	-F restrictions=null
```

Note: `gh` uses your local authentication (`gh auth login`).

## License

See [LICENSE](LICENSE) for details.
