# CI/CD Pipeline — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: DEVOPS
**Date**: 2026-03-10
**Status**: Accepted

---

## Overview

GitHub Actions CI/CD on free tier. Every push to any branch triggers the full test suite. Merges/pushes to `main` additionally trigger deployment to Fly.io. Trunk-Based Development: `main` is always deployable.

---

## Complete `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: ["**"]
  pull_request:
    branches: ["main"]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  RUBY_VERSION: "4.0"
  RAILS_ENV: test
  DATABASE_URL: postgres://postgres:postgres@localhost:5432/ruby_learn_test
  RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}

jobs:
  # ─── Test Jobs ───────────────────────────────────────────────────────────────

  test-unit:
    name: "Tests: Unit & Service"
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: ruby_learn_test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
          bundler-cache: true

      - name: Set up database
        run: |
          bin/rails db:create
          bin/rails db:schema:load
          bin/rails db:seed

      - name: Run unit and service tests
        run: bundle exec rspec spec/models spec/services --format progress --format json --out tmp/rspec-unit.json

      - name: Upload unit test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: rspec-unit-results
          path: tmp/rspec-unit.json
          retention-days: 7

  test-integration:
    name: "Tests: Integration"
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: ruby_learn_test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
          bundler-cache: true

      - name: Set up database
        run: |
          bin/rails db:create
          bin/rails db:schema:load
          bin/rails db:seed

      - name: Run integration tests
        run: bundle exec rspec spec/requests spec/mailers spec/jobs --format progress --format json --out tmp/rspec-integration.json

      - name: Upload integration test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: rspec-integration-results
          path: tmp/rspec-integration.json
          retention-days: 7

  test-system:
    name: "Tests: System / Acceptance"
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: ruby_learn_test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
          bundler-cache: true

      - name: Install Chrome (for Selenium/Capybara)
        uses: browser-actions/setup-chrome@latest
        with:
          chrome-version: stable

      - name: Set up database
        run: |
          bin/rails db:create
          bin/rails db:schema:load
          bin/rails db:seed

      - name: Run system and acceptance tests
        env:
          CAPYBARA_DRIVER: selenium_chrome_headless
        run: bundle exec rspec spec/system spec/features --format progress --format json --out tmp/rspec-system.json

      - name: Upload system test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: rspec-system-results
          path: tmp/rspec-system.json
          retention-days: 7

      - name: Upload screenshots on failure
        uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: capybara-screenshots
          path: tmp/capybara/
          retention-days: 3

  # ─── Deploy Job ──────────────────────────────────────────────────────────────

  deploy:
    name: "Deploy to Fly.io"
    runs-on: ubuntu-latest
    needs: [test-unit, test-integration, test-system]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment: production

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Fly CLI
        uses: superfly/flyctl-actions/setup-flyctl@master

      - name: Deploy to Fly.io
        run: flyctl deploy --remote-only --wait-timeout 300
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}

      - name: Tag production deploy
        run: |
          TAG="v$(date -u +%Y-%m-%d)-${GITHUB_SHA::7}"
          git tag "$TAG"
          git push origin "$TAG"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Verify deployment health
        run: |
          APP_URL=$(flyctl status --json | jq -r '.Hostname' || echo "")
          if [ -n "$APP_URL" ]; then
            echo "Checking health at https://${APP_URL}/up"
            curl --retry 5 --retry-delay 10 --retry-connrefused \
              -f "https://${APP_URL}/up" \
              -o /dev/null -s -w "HTTP status: %{http_code}\n"
          else
            echo "Could not determine app hostname; skipping health check"
          fi
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

---

## Secrets Required

Configure these in GitHub repository Settings → Secrets and variables → Actions:

| Secret | Description | Where to get it |
|--------|-------------|-----------------|
| `FLY_API_TOKEN` | Fly.io personal access token for deployment | `fly auth token` (local CLI) or Fly.io dashboard |
| `RAILS_MASTER_KEY` | Rails credentials decryption key | `config/master.key` file (git-ignored; copy contents) |

Note: `DATABASE_URL` and `POSTMARK_API_TOKEN` are Fly.io secrets (set via `fly secrets set`), not GitHub secrets. They are not needed by CI — the test suite uses the postgres service container and does not call Postmark.

---

## Parallelism Strategy

Three parallel test jobs reduce total CI time:

| Job | Spec paths | Typical content | Approx time |
|-----|-----------|-----------------|-------------|
| `test-unit` | `spec/models`, `spec/services` | SM2Engine, ScoreCalculator, QueueBuilder, ActiveRecord validations | 1–2 min |
| `test-integration` | `spec/requests`, `spec/mailers`, `spec/jobs` | Controller request specs, mailer specs, background job specs | 2–3 min |
| `test-system` | `spec/system`, `spec/features` | Capybara + Selenium acceptance tests (keyboard navigation, session flow) | 3–5 min |

Total wall-clock time with parallelism: ~5–6 minutes. All three jobs must pass before deploy is allowed.

The `deploy` job uses `needs: [test-unit, test-integration, test-system]` — all three gates must be green.

---

## Trunk-Based Development CI Gates

Every push to any branch:
- All three test jobs run in parallel.
- No deploy is triggered (deploy only on `main`).

Merge/push to `main`:
- All three test jobs run in parallel.
- If all pass: `deploy` job runs automatically.
- If any fail: deploy is blocked; push is never deployed.

The `concurrency` block with `cancel-in-progress: true` cancels in-flight runs for the same branch when a new push arrives — prevents queue buildup on feature branches with rapid iteration.

---

## Branch Protection Rules (GitHub)

Configure at: Repository Settings → Branches → Branch protection rules → Add rule for `main`

```
Branch name pattern: main

Required status checks (require these to pass before merging):
  - Tests: Unit & Service
  - Tests: Integration
  - Tests: System / Acceptance

Settings:
  [x] Require status checks to pass before merging
  [x] Require branches to be up to date before merging
  [x] Do not allow bypassing the above settings
  [ ] Allow force pushes — DISABLED
  [ ] Allow deletions — DISABLED
```

These rules ensure:
- No code reaches `main` without passing CI.
- No force-pushes can override the protection.
- Short-lived feature branches must rebase/merge from `main` before merging back.

---

## Caching Strategy

`ruby/setup-ruby@v1` with `bundler-cache: true` caches the bundled gems between runs using the `Gemfile.lock` hash as cache key. This is the primary cache — reduces CI time by 60–90 seconds per job by skipping `bundle install` on unchanged gems.

No additional caching is needed for this setup. Asset precompilation occurs in the Docker build (remote build on Fly.io via `--remote-only`), not in CI.

---

## `RAILS_MASTER_KEY` in CI

The test suite requires `RAILS_MASTER_KEY` to decrypt `config/credentials.yml.enc`. For CI:
1. Store the value of `config/master.key` as GitHub secret `RAILS_MASTER_KEY`.
2. The workflow exposes it as an env variable: `RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}`.

If the test suite does not reference encrypted credentials (and uses only env-var-based config in test), this can be omitted. Recommended to include it for consistency with production config loading.
