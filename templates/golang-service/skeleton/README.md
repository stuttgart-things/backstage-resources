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

## Available Tasks

```bash
task --list
```

| Task | Description |
|------|-------------|
| `task build` | Build the binary |
| `task run` | Run the application |
| `task test` | Run tests |
| `task test-coverage` | Run tests with coverage report |
| `task lint` | Run golangci-lint |
| `task fmt` | Format code |
| `task tidy` | Tidy and verify go modules |
| `task clean` | Clean build artifacts |

## Project Structure

```
.
├── main.go           # Application entry point
├── go.mod            # Go module definition
├── Taskfile.yaml     # Task automation
├── catalog-info.yaml # Backstage component definition
└── README.md         # This file
```

## License

See [LICENSE](LICENSE) for details.
