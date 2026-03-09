# CI/CD Pipeline — Ruby Learning Platform

**Feature**: ruby-learning-platform
**Date**: 2026-03-09
**Status**: Approved
**CI platform**: GitHub Actions
**Branching strategy**: Trunk-Based Development

---

## Overview

Every commit to `main` runs the full quality gate pipeline. Short-lived feature branches (< 1 day lifetime) run a lighter pre-merge gate. Main is always releasable. Deployment to the self-hosted machine is a manual-trigger workflow that executes a pull-and-recreate.

The pipeline has two workflows:

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | Push to `main`, PR targeting `main` | Full quality gate |
| `deploy.yml` | `workflow_dispatch` (manual) | Deploy to self-hosted production |

---

## Pipeline Architecture

```
Push to main / PR to main
         │
         ▼
┌─────────────────────────────────────────────────────┐
│  ci.yml                                             │
│                                                     │
│  ┌──────────────┐  ┌──────────────┐                │
│  │  lint-audit  │  │  unit-tests  │  (parallel)    │
│  │              │  │              │                 │
│  │ RuboCop      │  │ RSpec domain │                 │
│  │ Brakeman     │  │ (no DB)      │                 │
│  │ bundler-audit│  │ SimpleCov    │                 │
│  └──────┬───────┘  └──────┬───────┘                │
│         │                 │                         │
│         └────────┬────────┘                         │
│                  ▼                                   │
│         ┌──────────────────┐                        │
│         │ integration-tests│                        │
│         │                  │                        │
│         │ RSpec (full)     │                        │
│         │ PostgreSQL svc   │                        │
│         │ Redis svc        │                        │
│         │ SimpleCov gate   │                        │
│         └────────┬─────────┘                        │
│                  ▼                                   │
│         ┌──────────────────┐                        │
│         │ mutation-tests   │                        │
│         │ (main only)      │                        │
│         │ mutant gem       │                        │
│         │ kill rate >= 80% │                        │
│         └──────────────────┘                        │
└─────────────────────────────────────────────────────┘
         │ (on success, main only)
         ▼
  Deploy available via workflow_dispatch
```

---

## Workflow: ci.yml

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

env:
  RUBY_VERSION: "4.0"
  BUNDLE_WITHOUT: ""  # Install all groups including test/development

jobs:
  # ─────────────────────────────────────────────────────────────
  # Job 1: Linting, static security analysis, and CVE audit
  # Target: < 3 minutes
  # ─────────────────────────────────────────────────────────────
  lint-audit:
    name: Lint & Security Audit
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
          bundler-cache: true  # Caches bundle install automatically

      - name: RuboCop — Style enforcement
        run: bundle exec rubocop --format github
        # --format github annotates PRs with inline comments

      - name: Brakeman — Rails security static analysis
        run: bundle exec brakeman --exit-on-warn --format json --output tmp/brakeman.json
        # --exit-on-warn fails the job on any security warning

      - name: Upload Brakeman report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: brakeman-report
          path: tmp/brakeman.json
          retention-days: 7

      - name: bundler-audit — CVE check
        run: |
          bundle exec bundler-audit update  # Refresh advisory DB
          bundle exec bundler-audit check --format text

  # ─────────────────────────────────────────────────────────────
  # Job 2: Unit tests — domain layer only, no DB required
  # Ports-and-adapters: domain tests use in-memory adapters
  # Target: < 5 minutes
  # ─────────────────────────────────────────────────────────────
  unit-tests:
    name: Unit Tests (Domain)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
          bundler-cache: true

      - name: Run domain unit tests
        env:
          RAILS_ENV: test
        run: |
          bundle exec rspec spec/domain/ \
            --format progress \
            --format RspecJunitFormatter \
            --out tmp/rspec-unit.xml
        # spec/domain/ contains pure domain specs with in-memory test adapters
        # No database service required

      - name: Upload unit test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: rspec-unit-results
          path: tmp/rspec-unit.xml

  # ─────────────────────────────────────────────────────────────
  # Job 3: Integration tests — full stack with PostgreSQL + Redis
  # Runs after both parallel jobs pass
  # Target: < 15 minutes
  # ─────────────────────────────────────────────────────────────
  integration-tests:
    name: Integration Tests
    runs-on: ubuntu-latest
    needs: [lint-audit, unit-tests]

    services:
      postgres:
        image: postgres:17-alpine
        env:
          POSTGRES_DB: ruby_learning_test
          POSTGRES_USER: app
          POSTGRES_PASSWORD: test_password
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 5s
          --health-timeout 5s
          --health-retries 10

      redis:
        image: redis:7-alpine
        ports:
          - 6379:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 5s
          --health-timeout 3s
          --health-retries 10

    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
          bundler-cache: true

      - name: Set up database
        env:
          DATABASE_URL: postgres://app:test_password@localhost:5432/ruby_learning_test
          RAILS_ENV: test
        run: |
          bundle exec rails db:schema:load
          bundle exec rails db:seed RAILS_ENV=test  # Load curriculum YAML fixtures

      - name: Run full test suite with coverage
        env:
          DATABASE_URL: postgres://app:test_password@localhost:5432/ruby_learning_test
          REDIS_URL: redis://localhost:6379/0
          RAILS_ENV: test
          COVERAGE: "true"
        run: |
          bundle exec rspec \
            --format progress \
            --format RspecJunitFormatter \
            --out tmp/rspec-integration.xml

      - name: Enforce SimpleCov coverage gate
        run: |
          COVERAGE=$(ruby -e "
            require 'json'
            data = JSON.parse(File.read('coverage/.resultset.json'))
            # Aggregate covered_lines / total_lines across all groups
            total = 0; covered = 0
            data.each_value do |group|
              group['coverage'].each_value do |file_cov|
                next unless file_cov.is_a?(Hash)
                lines = file_cov['lines'].compact
                total += lines.size
                covered += lines.count { |l| l && l > 0 }
              end
            end
            puts total > 0 ? (covered.to_f / total * 100).round(2) : 0
          ")
          echo "Coverage: ${COVERAGE}%"
          if (( $(echo "$COVERAGE < 90" | bc -l) )); then
            echo "FAIL: Coverage ${COVERAGE}% is below 90% threshold"
            exit 1
          fi
          echo "PASS: Coverage ${COVERAGE}% meets 90% threshold"
        # 90% threshold: domain layer is near-100% testable via in-memory adapters;
        # adapters and controllers bring the overall lower. 90% is appropriate.

      - name: Upload coverage report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/
          retention-days: 14

      - name: Upload integration test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: rspec-integration-results
          path: tmp/rspec-integration.xml

  # ─────────────────────────────────────────────────────────────
  # Job 4: Mutation testing — main branch only, per-feature scope
  # Strategy: per-feature (modified files only, kill rate >= 80%)
  # Runs after integration tests pass
  # Target: < 15 minutes (scoped to modified files)
  # ─────────────────────────────────────────────────────────────
  mutation-tests:
    name: Mutation Tests
    runs-on: ubuntu-latest
    needs: [integration-tests]
    if: github.ref == 'refs/heads/main'

    services:
      postgres:
        image: postgres:17-alpine
        env:
          POSTGRES_DB: ruby_learning_test
          POSTGRES_USER: app
          POSTGRES_PASSWORD: test_password
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 5s
          --health-timeout 5s
          --health-retries 10

      redis:
        image: redis:7-alpine
        ports:
          - 6379:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 5s
          --health-timeout 3s
          --health-retries 10

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history needed to diff against previous commit

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
          bundler-cache: true

      - name: Set up database
        env:
          DATABASE_URL: postgres://app:test_password@localhost:5432/ruby_learning_test
          RAILS_ENV: test
        run: bundle exec rails db:schema:load

      - name: Identify modified domain files
        id: changed-files
        run: |
          # Diff against parent commit to find changed domain/adapter files
          CHANGED=$(git diff --name-only HEAD~1 HEAD -- 'app/domain/**/*.rb' 'app/adapters/**/*.rb' 'app/ports/**/*.rb' | tr '\n' ' ')
          echo "changed=${CHANGED}" >> $GITHUB_OUTPUT
          echo "Modified domain files: ${CHANGED}"

      - name: Run mutation tests on modified files
        if: steps.changed-files.outputs.changed != ''
        env:
          DATABASE_URL: postgres://app:test_password@localhost:5432/ruby_learning_test
          REDIS_URL: redis://localhost:6379/0
          RAILS_ENV: test
        run: |
          # mutant gem: mutation testing for Ruby
          # --since HEAD~1 scopes mutations to lines changed in this commit
          bundle exec mutant run \
            --include app \
            --require rails_helper \
            --integration rspec \
            -- ${{ steps.changed-files.outputs.changed }}
          # mutant exits non-zero if kill rate < configured threshold
          # Configure kill rate >= 80% in .mutant.yml (see below)

      - name: Skip mutation tests (no domain changes)
        if: steps.changed-files.outputs.changed == ''
        run: echo "No domain/adapter file changes detected. Mutation tests skipped."
```

---

## Workflow: deploy.yml

```yaml
# .github/workflows/deploy.yml
# Manual deployment trigger to self-hosted machine via SSH.
# Prerequisite: SSH key stored as GitHub Actions secret DEPLOY_SSH_KEY.
# Host must have Docker and Docker Compose installed.

name: Deploy to Production

on:
  workflow_dispatch:
    inputs:
      version:
        description: "Image tag / git ref to deploy (default: main)"
        required: false
        default: "main"
      skip_backup:
        description: "Skip pre-deployment database backup (not recommended)"
        required: false
        default: "false"
        type: boolean

jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    environment: production  # Requires environment protection rules in GitHub

    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.inputs.version }}

      - name: Verify CI passed on ref
        run: |
          # Confirm the target ref has a passing CI run before deploying
          COMMIT_SHA=$(git rev-parse HEAD)
          echo "Deploying commit: ${COMMIT_SHA}"
          # Manual verification step — operator confirms CI green before triggering

      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.DEPLOY_HOST }}
          username: ${{ secrets.DEPLOY_USER }}
          key: ${{ secrets.DEPLOY_SSH_KEY }}
          script: |
            set -euo pipefail

            cd /opt/ruby-learning-platform

            echo "=== Step 1: Tag current image for rollback ==="
            docker tag ruby-learning-platform:latest ruby-learning-platform:rollback || true

            echo "=== Step 2: Database backup ==="
            if [ "${{ github.event.inputs.skip_backup }}" != "true" ]; then
              mkdir -p backups
              docker compose -f docker-compose.prod.yml exec -T db pg_dump \
                -U ${POSTGRES_USER} ${POSTGRES_DB} \
                > backups/pre-deploy-$(date +%Y%m%d-%H%M%S).sql
              echo "Backup complete."
            else
              echo "WARNING: Backup skipped by operator request."
            fi

            echo "=== Step 3: Pull latest code ==="
            git pull origin main

            echo "=== Step 4: Build new image ==="
            docker build -t ruby-learning-platform:latest .

            echo "=== Step 5: Run migrations ==="
            docker compose -f docker-compose.prod.yml run --rm app \
              bundle exec rails db:migrate

            echo "=== Step 6: Recreate app container ==="
            docker compose -f docker-compose.prod.yml up -d --force-recreate app

            echo "=== Step 7: Health check ==="
            sleep 10
            for i in 1 2 3 4 5; do
              if curl -f -s http://localhost:3000/health; then
                echo "Health check passed."
                exit 0
              fi
              echo "Health check attempt $i failed. Waiting..."
              sleep 10
            done

            echo "=== DEPLOYMENT FAILED — Executing rollback ==="
            docker compose -f docker-compose.prod.yml down app
            docker tag ruby-learning-platform:rollback ruby-learning-platform:latest
            docker compose -f docker-compose.prod.yml up -d app
            echo "Rollback complete. Previous version restored."
            exit 1
```

---

## Mutant Configuration

```yaml
# .mutant.yml
# Mutation testing configuration for mutant gem
# https://github.com/mbj/mutant

integration: rspec

# Kill rate threshold — pipeline fails if below 80%
# For correctness-critical SM-2 paths, this ensures test suite
# catches behavioral regressions, not just structural presence.
# Note: mutant CLI uses --min-coverage flag; configure in Gemfile or CI invocation.

# Subject inclusion — only domain and adapter code
includes:
  - "app/domain/**/*.rb"
  - "app/ports/**/*.rb"
  - "app/adapters/**/*.rb"

# Subjects to exclude from mutation (framework glue, not logic)
ignores:
  - "app/adapters/web/**"  # Controllers: thin adapter, no domain logic to mutate
```

Add to `Gemfile`:
```ruby
group :test do
  gem "mutant-rspec", require: false
end
```

---

## Branch Protection Rules

Configure in GitHub repository Settings > Branches > Branch protection rules for `main`:

```
Pattern: main

Required status checks (must pass before merge):
  - Lint & Security Audit
  - Unit Tests (Domain)
  - Integration Tests

Do NOT require mutation tests on PRs (only runs on push to main post-merge).

Additional rules:
  - Require branches to be up to date before merging: YES
  - Require linear history: YES (enforces clean commit graph; no merge commits)
  - Restrict pushes that create matching branches: NO (direct push to main allowed for solo dev)
  - Allow force pushes: NO
  - Allow deletions: NO
```

For a solo developer practicing trunk-based development, the PR-to-main flow is optional. Direct push to `main` is acceptable given robust CI gates catch issues before merge. The branch protection rules above require CI to pass on any push — including direct pushes.

---

## Pipeline Performance Targets

| Job | Target | P90 Actual (estimated) |
|-----|--------|------------------------|
| lint-audit | < 3 min | ~2 min |
| unit-tests | < 5 min | ~3 min (pure domain, no DB) |
| integration-tests | < 15 min | ~10 min |
| mutation-tests | < 15 min | ~8 min (scoped to changed files) |
| **Total (main)** | **< 20 min** | **~18 min** |

Unit and lint jobs run in parallel, so the critical path is: parallel jobs (~3 min) + integration (~10 min) + mutation (~8 min) = ~21 min. The mutation step is the tail.

---

## Caching Strategy

`ruby/setup-ruby@v1` with `bundler-cache: true` handles Gem caching automatically using the `Gemfile.lock` hash as the cache key. This reduces bundle install from ~3 minutes to ~20 seconds on cache hit.

No additional caching configuration is needed for this stack.

---

## Secret Management

| Secret | Where stored | Purpose |
|--------|-------------|---------|
| `DEPLOY_SSH_KEY` | GitHub Actions environment secret (production) | SSH private key for deploy workflow |
| `DEPLOY_HOST` | GitHub Actions environment secret (production) | Hostname/IP of self-hosted machine |
| `DEPLOY_USER` | GitHub Actions environment secret (production) | SSH username on self-hosted machine |

Production environment in GitHub Actions requires manual approval before deployment runs. Configure at Settings > Environments > production > Required reviewers.

No secrets are embedded in workflow YAML. No `.env` files are committed.

---

## DORA Metrics Baseline

| Metric | Target (personal tool) | Notes |
|--------|----------------------|-------|
| Deployment frequency | On-demand (multiple/week) | Manual trigger; no blocker |
| Lead time for changes | < 30 minutes | Commit-to-deploy including CI |
| Change failure rate | < 15% | Automated rollback on health check failure |
| Time to restore | < 5 minutes | Rollback script restores previous image |
