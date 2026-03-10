# Platform Architecture — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: DEVOPS
**Date**: 2026-03-10
**Status**: Accepted

---

## Overview

Single-machine deployment on Fly.io. One Rails 8.1 process (web + Solid Queue workers co-located), one Fly Postgres database. No load balancer, no auto-scaling, no multi-region — single user, no SLA requirement. Recreate deployment strategy: stop old machine, start new one.

---

## Fly.io App Configuration (`fly.toml`)

```toml
# fly.toml — Ruby Learning Platform
# Replace <APP_NAME> with your chosen Fly.io app name (e.g., ruby-learn-prod)

app = "<APP_NAME>"
primary_region = "iad"   # US East (IAD) — choose closest region to user

[build]
  dockerfile = "Dockerfile"

[env]
  RAILS_ENV = "production"
  RAILS_LOG_TO_STDOUT = "true"
  RAILS_SERVE_STATIC_FILES = "true"
  SOLID_QUEUE_IN_PUMA = "true"

[http_service]
  internal_port = 3000
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 0

  [http_service.concurrency]
    type = "requests"
    hard_limit = 25
    soft_limit = 20

[[http_service.checks]]
  interval = "30s"
  timeout = "10s"
  grace_period = "30s"
  method = "GET"
  path = "/up"

[vm]
  size = "shared-cpu-1x"
  memory = "256mb"

[deploy]
  strategy = "immediate"   # Recreate: stop existing machine, deploy new one
  release_command = "bin/rails db:migrate"
```

**Key decisions**:
- `strategy = "immediate"`: Implements the agreed Recreate deployment. Fly stops the running machine and starts the replacement. Zero-downtime strategies (rolling, canary) are not warranted for a single-user app.
- `auto_stop_machines = true` / `min_machines_running = 0`: Fly's free-tier optimization — machine sleeps when idle, wakes on first request. Acceptable for single user.
- `release_command = "bin/rails db:migrate"`: Migrations run before the new machine starts serving traffic.
- `SOLID_QUEUE_IN_PUMA = "true"`: Starts Solid Queue workers in-process with Puma (no separate worker process or Procfile required).

---

## Fly Postgres Configuration

```bash
# Provision (run once from local machine with flyctl installed)
fly postgres create \
  --name <APP_NAME>-db \
  --region iad \
  --vm-size shared-cpu-1x \
  --volume-size 1 \
  --initial-cluster-size 1

# Attach to app (sets DATABASE_URL secret automatically)
fly postgres attach <APP_NAME>-db --app <APP_NAME>
```

| Parameter | Value | Notes |
|-----------|-------|-------|
| Plan | shared-cpu-1x, 256 MB RAM | Free tier eligible; sufficient for single-user |
| PostgreSQL version | 16 | Matches architecture requirement |
| Volume size | 1 GB | Adequate for single-user SM-2 data |
| Cluster size | 1 (single node) | No HA required |
| Connection method | `fly postgres attach` | Sets `DATABASE_URL` secret automatically |

**Connection pooling**: Rails default connection pool (5 connections) is sufficient. PgBouncer not required at this scale.

---

## Environment Variables and Secrets Inventory

Secrets are stored in Fly.io's encrypted secrets store (never in source code or `fly.toml`).

### Required Secrets (set via `fly secrets set`)

| Secret | Description | How to obtain |
|--------|-------------|---------------|
| `RAILS_MASTER_KEY` | Decrypts `config/credentials.yml.enc` | Contents of `config/master.key` (git-ignored) |
| `DATABASE_URL` | PostgreSQL connection string | Set automatically by `fly postgres attach` |
| `POSTMARK_API_TOKEN` | Postmark server API token | Postmark dashboard → Server → API Tokens |
| `SECRET_KEY_BASE` | Rails session signing key | Generate with `bin/rails secret` |

### Environment Variables in `fly.toml` (non-sensitive)

| Variable | Value | Purpose |
|----------|-------|---------|
| `RAILS_ENV` | `production` | Rails environment |
| `RAILS_LOG_TO_STDOUT` | `true` | Directs Rails logs to stdout for Fly log capture |
| `RAILS_SERVE_STATIC_FILES` | `true` | Serves assets from `/public` (no Nginx layer) |
| `SOLID_QUEUE_IN_PUMA` | `true` | Runs Solid Queue workers inside Puma process |

### Setting secrets

```bash
fly secrets set \
  RAILS_MASTER_KEY=<value-from-config/master.key> \
  POSTMARK_API_TOKEN=<value-from-postmark-dashboard> \
  SECRET_KEY_BASE=$(bin/rails secret) \
  --app <APP_NAME>
# DATABASE_URL is set by fly postgres attach — no manual step needed
```

---

## Dockerfile Design Guidance

Rails 8.1 generates a production-ready Dockerfile via `./bin/rails generate dockerfile`. The generated file implements multi-stage build. Key configuration points:

```dockerfile
# Stage 1: Build stage
# Base: ruby:4.0-slim (or official Ruby 4.0 image when available)
# Install: build-essential, libpq-dev, nodejs (for asset precompilation via import maps)
# Bundle install with --without development test
# Precompile assets: SECRET_KEY_BASE=placeholder bin/rails assets:precompile

# Stage 2: Runtime stage
# Base: ruby:4.0-slim
# Copy: bundled gems, compiled assets from build stage
# Expose port 3000
# CMD: bin/rails server -b 0.0.0.0 -p 3000
```

**Critical configuration points**:

1. **Ruby version**: Pin to `4.0` in both `.ruby-version` and `Dockerfile FROM` directive. If `ruby:4.0-slim` is not yet on Docker Hub, use `ruby:4.0-rc-slim` or the appropriate pre-release tag.

2. **Asset precompilation in build stage**: Assets must be precompiled during Docker build, not at runtime. The `SECRET_KEY_BASE=placeholder` trick allows precompilation without the real secret.

3. **Solid Queue in same process**: No `Procfile` or separate worker `CMD` required. `SOLID_QUEUE_IN_PUMA=true` environment variable triggers the Puma plugin. Verify `config/puma.rb` includes:
   ```ruby
   plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"] == "true"
   ```

4. **Whenever cron in containers**: Whenever generates a `crontab` — this does not apply in a containerized Fly Machine. Use Solid Queue's `config/recurring.yml` instead for the nightly job:

   ```yaml
   # config/recurring.yml
   queue_builder_nightly:
     class: QueueBuilderJob
     schedule: "0 2 * * *"   # 2:00 AM UTC daily
     queue: default
   ```

   This is the container-native equivalent of the Whenever cron schedule. Set `config.solid_queue.recurring_schedule` or use the YAML file per Solid Queue docs.

5. **Database migration**: Handled by `release_command` in `fly.toml` — runs `bin/rails db:migrate` before traffic is routed to the new machine.

6. **Health check**: Ensure `GET /up` returns 200 before the Fly health check marks the machine healthy. Rails 7.2+ includes `Rails::HealthController` at this route by default.

---

## Fly Machines Scheduling

The Whenever gem generates a system crontab, which does not run inside a Docker container on Fly Machines. The nightly background job is scheduled instead via **Solid Queue's recurring jobs** (`config/recurring.yml`).

```yaml
# config/recurring.yml
production:
  queue_builder_nightly:
    class: QueueBuilderJob
    schedule: "0 2 * * *"   # Every day at 2:00 AM UTC
    queue: default
    priority: 0
```

Solid Queue reads this file at startup and registers the recurring task. Because `SOLID_QUEUE_IN_PUMA=true`, the Solid Queue scheduler process starts with Puma and manages the cron internally. No external cron, no Fly scheduled tasks, no Whenever crontab output needed.

The `EmailDispatchJob` is enqueued by `QueueBuilderJob` on completion, not scheduled independently.

---

## Free Tier Cost Estimate

| Resource | Plan | Estimated Monthly Cost |
|----------|------|----------------------|
| Fly.io App Machine (shared-cpu-1x, 256 MB) | Pay-per-use with auto-stop | ~$0–$2 (sleeps when idle; free allowance covers light use) |
| Fly Postgres (shared-cpu-1x, 256 MB, 1 GB volume) | Free tier | ~$0 (within Fly free allowance for single machine) |
| Fly.io networking / TLS | Included | $0 |
| GitHub Actions CI | Free tier (2,000 min/month) | $0 |
| Postmark email | Free tier (100 emails/month) | $0 |
| **Total** | | **~$0–$2/month** |

Note: Fly.io free tier as of 2026 includes 3 shared-cpu-1x 256 MB machines and 3 GB persistent volume storage. This deployment uses 1 app machine + 1 Postgres machine, which is within the free allowance. Verify current Fly.io pricing at https://fly.io/docs/about/pricing/ as free tier terms may change.
