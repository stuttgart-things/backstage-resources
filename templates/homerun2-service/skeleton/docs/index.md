# ${{ values.fullName }}

${{ values.description }}
{%- if values.serviceType == "pitcher" %}

## Quick Start

```bash
# Run with Redis
export REDIS_ADDR=localhost REDIS_PORT=6379 REDIS_STREAM=${{ values.redisStream }} AUTH_TOKEN=mysecret
go run .

# Dev mode (no Redis)
PITCHER_MODE=file AUTH_TOKEN=test go run .
```

## API Endpoints

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/health` | `GET` | None | Health check |
| `/pitch` | `POST` | Bearer token | Submit a message to Redis Streams |

## Architecture

```
HTTP POST /pitch → ${{ values.fullName }} → Redis Stream (${{ values.redisStream }})
```
{%- endif %}
{%- if values.serviceType == "catcher" %}

## Quick Start

```bash
export REDIS_ADDR=localhost REDIS_PORT=6379 REDIS_STREAM=${{ values.redisStream }}
go run .
```

## Architecture

```
Redis Stream (${{ values.redisStream }}) → ${{ values.fullName }} → slog output
```
{%- endif %}
