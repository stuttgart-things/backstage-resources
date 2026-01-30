# ${{ values.name }}

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

## License

See [LICENSE](LICENSE) for details.
