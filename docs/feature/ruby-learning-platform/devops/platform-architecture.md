# Platform Architecture — Ruby Learning Platform

**Feature**: ruby-learning-platform
**Date**: 2026-03-09
**Status**: Approved
**Deployment target**: On-premise self-hosted (Docker Compose)

---

## Overview

The platform runs as a set of Docker Compose services on a single self-managed machine. GitHub Actions handles CI. Deployment is a pull-and-recreate operation executed on the host machine — no Kubernetes, no PaaS, no cloud scheduler.

This is a single-user personal tool. Complexity is deliberately constrained to what one developer can operate without toil.

---

## Rejected Simpler Alternatives

### Alternative 1: Native Ruby process (no Docker)

- **What**: Run `bundle exec puma` directly on the host OS with a system-installed PostgreSQL and Redis.
- **Expected impact**: Works for ~100% of functional requirements. Zero container overhead.
- **Why insufficient**: Host OS dependency management is fragile across OS upgrades. No environment parity between developer laptop and production host. Dependency version drift between Ruby, PostgreSQL, and Redis becomes a maintenance burden over months. Docker provides reproducible environments at negligible cost for a personal tool.

### Alternative 2: Single Docker container (all-in-one)

- **What**: One container running Rails + PostgreSQL + Redis (s6-overlay or similar init).
- **Expected impact**: Simpler compose file; single container to manage.
- **Why insufficient**: Violates immutability principle — data volumes must be separate from app containers. PostgreSQL and Redis upgrades would require all-in-one image rebuilds. The service separation provided by Compose (per-service restart, per-service health checks) eliminates entire categories of operational failure.

---

## Service Topology

```
┌──────────────────────────────────────────────────────────────┐
│  Docker Compose (self-hosted host)                           │
│                                                              │
│  ┌─────────────┐   ┌─────────────┐   ┌──────────────────┐  │
│  │    app      │   │   worker    │   │     jaeger       │  │
│  │ Rails/Puma  │   │  Sidekiq    │   │  OTLP receiver   │  │
│  │  port 3000  │   │ (post-MVP)  │   │  port 16686 UI   │  │
│  └──────┬──────┘   └──────┬──────┘   └──────────────────┘  │
│         │                 │                    ▲             │
│         │ SQL             │ SQL                │ OTLP/gRPC   │
│         ▼                 ▼                    │             │
│  ┌─────────────┐   ┌─────────────┐            │             │
│  │     db      │   │    redis    │    app ────►│             │
│  │  PostgreSQL │   │   Redis 7   │                          │
│  │     17      │   │             │                          │
│  └─────────────┘   └─────────────┘                          │
└──────────────────────────────────────────────────────────────┘
```

Services:

| Service | Image | Role | Ports exposed |
|---------|-------|------|---------------|
| `app` | Custom (build from Dockerfile) | Rails 8 / Puma 6 web server | 3000 (host-mapped) |
| `db` | `postgres:17-alpine` | PostgreSQL 17 data store | None (internal) |
| `redis` | `redis:7-alpine` | Job queue + session cache | None (internal) |
| `worker` | Same image as `app` | Sidekiq background jobs (post-MVP, commented out) | None |
| `jaeger` | `jaegertracing/all-in-one:latest` | OTLP trace receiver + UI | 16686 (UI), 4317 (gRPC) |
| `mailpit` | `axllent/mailpit:latest` | Local SMTP catcher + web UI (**dev only**) | 1025 (SMTP), 8025 (UI) |

---

## Dockerfile

```dockerfile
# syntax=docker/dockerfile:1
FROM ruby:4.0-slim AS base

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      curl \
      git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Bundle install as a separate layer for cache efficiency
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test --jobs 4 --retry 3

# Copy application code
COPY . .

# Precompile assets in production build
ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}
RUN if [ "$RAILS_ENV" = "production" ]; then \
      SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile; \
    fi

EXPOSE 3000

# Health check at the OS layer (Docker daemon uses this)
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

---

## docker-compose.yml (Development)

```yaml
# docker-compose.yml — Development
# Uses bind-mounted source code; RAILS_ENV=development; no asset precompile required.

services:
  db:
    image: postgres:17-alpine
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-ruby_learning_development}
      POSTGRES_USER: ${POSTGRES_USER:-app}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?POSTGRES_PASSWORD required}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-app} -d ${POSTGRES_DB:-ruby_learning_development}"]
      interval: 5s
      timeout: 5s
      retries: 10
      start_period: 10s

  redis:
    image: redis:7-alpine
    command: redis-server --save 60 1 --loglevel warning
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 10
      start_period: 5s

  jaeger:
    image: jaegertracing/all-in-one:latest
    environment:
      COLLECTOR_OTLP_ENABLED: "true"
    ports:
      - "16686:16686"  # Jaeger UI
      - "4317:4317"    # OTLP gRPC receiver
    # In-memory storage: traces lost on restart — acceptable for local dev

  mailpit:
    image: axllent/mailpit:latest
    ports:
      - "1025:1025"   # SMTP (Rails Action Mailer sends here in development)
      - "8025:8025"   # Web UI — http://localhost:8025
    environment:
      MP_MAX_MESSAGES: 100
      MP_DATA_FILE: /data/mailpit.db
    volumes:
      - mailpit_data:/data

  app:
    build:
      context: .
      args:
        RAILS_ENV: development
    environment:
      RAILS_ENV: development
      DATABASE_URL: postgres://${POSTGRES_USER:-app}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB:-ruby_learning_development}
      REDIS_URL: redis://redis:6379/0
      OTEL_EXPORTER_OTLP_ENDPOINT: http://jaeger:4317
      OTEL_SERVICE_NAME: ruby-learning-platform
      RAILS_LOG_TO_STDOUT: "true"
      # Action Mailer — send to Mailpit in development
      SMTP_HOST: mailpit
      SMTP_PORT: "1025"
    volumes:
      - .:/app
      - bundle_cache:/usr/local/bundle
    ports:
      - "3000:3000"
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    command: bundle exec rails server -b 0.0.0.0

  # worker:  # Post-MVP: uncomment when Sidekiq jobs are introduced
  #   build:
  #     context: .
  #     args:
  #       RAILS_ENV: development
  #   environment:
  #     RAILS_ENV: development
  #     DATABASE_URL: postgres://${POSTGRES_USER:-app}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB:-ruby_learning_development}
  #     REDIS_URL: redis://redis:6379/0
  #   depends_on:
  #     db:
  #       condition: service_healthy
  #     redis:
  #       condition: service_healthy
  #   command: bundle exec sidekiq -C config/sidekiq.yml

volumes:
  postgres_data:
  redis_data:
  bundle_cache:
  mailpit_data:
```

---

## docker-compose.prod.yml (Production)

```yaml
# docker-compose.prod.yml — Production
# Run with: docker compose -f docker-compose.prod.yml up -d
# Requires .env.prod file or environment variables set on the host.

services:
  db:
    image: postgres:17-alpine
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    # No port exposure — database not accessible outside Docker network

  redis:
    image: redis:7-alpine
    command: redis-server --save 60 1 --loglevel warning --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
      start_period: 10s

  jaeger:
    image: jaegertracing/all-in-one:latest
    environment:
      COLLECTOR_OTLP_ENABLED: "true"
    volumes:
      - jaeger_data:/badger
    environment:
      SPAN_STORAGE_TYPE: badger
      BADGER_EPHEMERAL: "false"
      BADGER_DIRECTORY_VALUE: /badger/data
      BADGER_DIRECTORY_KEY: /badger/key
      COLLECTOR_OTLP_ENABLED: "true"
    ports:
      - "127.0.0.1:16686:16686"  # Jaeger UI — localhost only (no external exposure)
      - "4317:4317"               # OTLP gRPC (internal + app service)
    restart: unless-stopped

  app:
    image: ${APP_IMAGE:-ruby-learning-platform}:${APP_VERSION:-latest}
    environment:
      RAILS_ENV: production
      DATABASE_URL: postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379/0
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      OTEL_EXPORTER_OTLP_ENDPOINT: http://jaeger:4317
      OTEL_SERVICE_NAME: ruby-learning-platform
      RAILS_LOG_TO_STDOUT: "true"
      RAILS_SERVE_STATIC_FILES: "true"  # Puma serves assets; no nginx reverse proxy needed for 1 user
      # Action Mailer — external SMTP in production
      SMTP_HOST: ${SMTP_HOST}
      SMTP_PORT: ${SMTP_PORT:-587}
      SMTP_DOMAIN: ${SMTP_DOMAIN}
      SMTP_USERNAME: ${SMTP_USERNAME}
      SMTP_PASSWORD: ${SMTP_PASSWORD}
      SMTP_FROM: ${SMTP_FROM}
    ports:
      - "127.0.0.1:3000:3000"  # Bind to localhost — expose via host's nginx or SSH tunnel
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

  # worker:  # Post-MVP: uncomment when Sidekiq jobs are introduced
  #   image: ${APP_IMAGE:-ruby-learning-platform}:${APP_VERSION:-latest}
  #   environment:
  #     RAILS_ENV: production
  #     DATABASE_URL: postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}
  #     REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379/0
  #     SECRET_KEY_BASE: ${SECRET_KEY_BASE}
  #   depends_on:
  #     db:
  #       condition: service_healthy
  #     redis:
  #       condition: service_healthy
  #   restart: unless-stopped
  #   command: bundle exec sidekiq -C config/sidekiq.yml

volumes:
  postgres_data:
  redis_data:
  jaeger_data:
```

---

## Environment Variables

### .env.example

```bash
# Database
POSTGRES_DB=ruby_learning_production
POSTGRES_USER=app
POSTGRES_PASSWORD=change_me_strong_password

# Redis
REDIS_PASSWORD=change_me_redis_password

# Rails
SECRET_KEY_BASE=generate_with_rails_secret
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true

# OpenTelemetry
OTEL_SERVICE_NAME=ruby-learning-platform
OTEL_EXPORTER_OTLP_ENDPOINT=http://jaeger:4317

# Email / Action Mailer (production SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=example.com
SMTP_USERNAME=your-address@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM=ruby-learning-platform@example.com
ALERT_EMAIL_TO=your-address@example.com

# App URL (used in mailer links and health check cron)
APP_HOST=localhost
APP_PORT=3000

# Deployment metadata
APP_IMAGE=ruby-learning-platform
APP_VERSION=latest
```

Never commit `.env` or `.env.prod` to version control. Add both to `.gitignore`.

---

## Deployment Procedure (Recreate Strategy)

The chosen deployment strategy is **Recreate**: stop all containers, pull new image, start fresh. Appropriate for a single-user personal tool where brief downtime during deployment (30–60 seconds) is acceptable.

### Rollback Procedure (Define Before Deployment)

Rollback is the first step of any deployment plan.

```bash
# Tag the running image before deploying
docker tag ruby-learning-platform:latest ruby-learning-platform:rollback

# If new deployment fails, restore:
docker compose -f docker-compose.prod.yml down
docker tag ruby-learning-platform:rollback ruby-learning-platform:latest
docker compose -f docker-compose.prod.yml up -d

# If database migration introduced breaking schema changes,
# run the migration's `down` method before restoring image:
docker compose -f docker-compose.prod.yml run --rm app bundle exec rails db:rollback
```

### Deployment Steps

```bash
# 1. Pull latest code on the host
git pull origin main

# 2. Build new image
docker build -t ruby-learning-platform:latest .

# 3. Run pending migrations (before recreating app container)
docker compose -f docker-compose.prod.yml run --rm app bundle exec rails db:migrate

# 4. Recreate app container (brief downtime starts here)
docker compose -f docker-compose.prod.yml up -d --force-recreate app

# 5. Verify health
curl -f http://localhost:3000/health && echo "Deployment successful"

# 6. If health check fails within 2 minutes, execute rollback (see above)
```

---

## Volume Backup

PostgreSQL data must be backed up before any deployment with schema migrations.

```bash
# Backup before deployment
docker compose -f docker-compose.prod.yml exec db pg_dump \
  -U ${POSTGRES_USER} ${POSTGRES_DB} \
  > backups/pre-deploy-$(date +%Y%m%d-%H%M%S).sql

# Restore if needed
docker compose -f docker-compose.prod.yml exec -T db psql \
  -U ${POSTGRES_USER} ${POSTGRES_DB} \
  < backups/pre-deploy-TIMESTAMP.sql
```

---

## Network Design

All services communicate over a single Docker Compose default network (`ruby-learning-platform_default`). No service-to-service communication leaves the host machine. External access to the app is via `127.0.0.1:3000` — the operator exposes this via their own mechanism (nginx reverse proxy, SSH tunnel, or direct local access).

Jaeger UI binds to `127.0.0.1:16686` — accessible from the operator's browser on the same machine, not exposed to the network.

---

## ADR: Docker Compose over Kubernetes

**Decision**: Docker Compose for container orchestration.
**Context**: Single-user personal tool; single host; one developer operating the stack.
**Rationale**: Kubernetes introduces ~5 additional operational concerns (control plane management, RBAC, network policies, ingress controllers, storage provisioners) with zero user-facing benefit for a 1-user tool. Docker Compose provides environment reproducibility, service dependency ordering, and named volumes with minimal operator overhead. Revisit if traffic ever exceeds 1 user or deployment moves to multi-node.
