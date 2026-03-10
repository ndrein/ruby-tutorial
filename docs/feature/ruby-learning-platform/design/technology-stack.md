# Technology Stack — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: DESIGN
**Date**: 2026-03-10
**Status**: Accepted

---

## Summary Table

| Layer | Choice | License | Rationale |
|-------|--------|---------|-----------|
| Language | Ruby 4.0 | Ruby License (OSS) | Platform is a Ruby learning tool; Ruby-on-Ruby is dogfooding and appropriate |
| Framework | Ruby on Rails 8.1 | MIT | Full-stack framework with batteries-included: ORM, mailer, background jobs, asset pipeline |
| Database | PostgreSQL 16 | PostgreSQL License (OSS) | Relational model, ACID transactions, JSON support, strong Rails integration |
| Frontend | Hotwire (Turbo + Stimulus) | MIT | SSR with targeted DOM updates; no JS build pipeline; keyboard nav manageable in Stimulus |
| Email provider | Postmark | Commercial (free tier) | Transactional-only positioning; deliverability focus; developer-friendly API; free tier ≥100 emails/month |
| SM-2 implementation | Hand-rolled service object | N/A | Algorithm is ~15 lines; hand-rolling eliminates external dependency and ensures testability as pure function |
| Asset pipeline | Propshaft + Import Maps | MIT | Zero-config approach; no webpack/esbuild required; compatible with Rails 7.2 |
| Job queue | Solid Queue (Rails 8 backport) | MIT | DB-backed; no Redis required; sufficient for single-user nightly job; bundled with Rails 7.2+ |
| Background scheduler | Whenever gem | MIT | Cron DSL for Ruby; generates crontab entries; well-maintained |
| Testing — unit/integration | RSpec 3.x + FactoryBot | MIT | Industry standard for Rails; expressive; integrates with Capybara |
| Testing — acceptance | Capybara + Selenium/Chrome | MIT | Browser-level keyboard navigation testing requires real DOM interaction |
| Testing — mutation | Mutant | Commercial/OSS | Per-feature mutation testing as specified in CLAUDE.md |
| Hosting | Fly.io | Commercial | $5-20/month target; container-native; PostgreSQL add-on available; good Rails support |
| Ruby version manager | rbenv | MIT | Standard; CI-compatible |

---

## Language and Framework

### Ruby 4.0 on Rails 8.1

The platform is a Ruby syntax learning tool. Building it in Ruby is a direct embodiment of the product's purpose — the builder experiences the language while building the tool. Rails 8.1 provides:

- ActiveRecord ORM with PostgreSQL adapter (sm2 fields, review records, sessions)
- Action Mailer + Postmark adapter (daily email dispatch)
- Hotwire integration (Turbo Streams for exercise feedback without full page reload)
- Solid Queue built-in (nightly queue builder job)
- Built-in session management (secure cookie-based auth, no gem required for single-user)

No alternative framework considered seriously: Sinatra lacks the ORM/mailer/job infrastructure; a non-Rails stack would require assembling all these layers manually for no gain.

Rails 8.1 is the minimum compatible Rails version for Ruby 4.0.

See ADR-001.

---

## Database

### PostgreSQL 16

Single relational database. Schema is normalized: users, lessons, exercises, reviews, daily_queues, sessions. No polyglot persistence required — all data is relational with well-defined foreign keys.

PgBouncer is not required at single-user scale. Connection pooling via Rails connection pool (5 connections default) is sufficient.

See ADR-002.

---

## Frontend Approach

### Hotwire (Turbo + Stimulus)

The exercise interaction model requires:
1. Submit answer → receive feedback within 500ms (AC-005-02)
2. Timer countdown (client-side 30s countdown)
3. Keyboard shortcut handling (j/k, Enter, Esc, h, e, g+d sequence)
4. Session time display

Turbo Frames handle answer submission → feedback swap without full page reload. Stimulus controllers handle:
- `timer_controller`: 30-second countdown, auto-advance at 0
- `keyboard_controller`: shortcut routing, input-focused guard (AC-014-02)
- `session_controller`: session duration tracking (server-authoritative, client mirrors)

React or Vue would introduce a full JS build pipeline (webpack or esbuild), client-side state management, and API contracts between frontend and backend — all for a single-user tool where server-rendering is perfectly adequate. Rejected.

Plain ERB without Stimulus is insufficient: the 30-second timer, keyboard shortcut sequencing (g+d), and input-focus guards require JavaScript that benefits from a structured controller pattern.

See ADR-003.

---

## SM-2 Implementation

### Hand-rolled Ruby service object

The SM-2 algorithm is specified exactly in requirements (FR-2.3 through FR-2.6, NFR-5.1 through NFR-5.5). The core calculation is ~20 lines:

- Quality score derivation from answer_result + timer_seconds
- EF update formula: `EF' = EF + (0.1 - (5-q) * (0.08 + (5-q) * 0.02))`
- EF clamping to [1.3, 2.5]
- Interval calculation: I(1)=1, I(2)=6, I(n)=round(I(n-1) * EF)
- Reset on q < 3: interval = 1, repetitions = 0

No Ruby SM-2 gems are actively maintained and well-tested at production quality. Hand-rolling ensures the algorithm is a pure function (value-in → value-out, no side effects), directly unit-testable per NFR-5.5, and not subject to a third-party dependency's assumptions about data models.

See ADR-004.

---

## Email Delivery

### Postmark (free tier)

Free tier supports 100 emails/month — sufficient for single-user daily email (30 emails/month). Postmark's positioning as "transactional email only" (no bulk/marketing) matches the product's requirement that emails contain no promotional content (FR-4.7). Deliverability is excellent; API integration with Rails Action Mailer is one gem (`postmark-rails`).

SendGrid free tier (100 emails/day) is more generous but SendGrid's interface is cluttered with marketing features that create configuration risk (accidentally enabling tracking pixels, unsubscribe footers). Postmark's minimalism is the safer choice for a developer tool with explicit anti-marketing requirements.

See ADR-006.

---

## Asset Pipeline

### Propshaft + Import Maps

Rails 7.2 default for new applications. No bundling step required — JavaScript modules loaded via browser-native import maps. Stimulus is distributed as an ESM module and works without compilation. CSS served directly.

Sprockets + Webpacker not used: Sprockets is deprecated-path; Webpacker is retired. Esbuild would add a build step for no benefit given the minimal JavaScript footprint.

---

## Background Jobs

### Solid Queue + Whenever gem

Solid Queue (Rails 7.2+): database-backed job queue using PostgreSQL. No Redis or Sidekiq required. For a single-user tool with a single nightly job (queue builder + email dispatch), Solid Queue is perfectly adequate.

Whenever generates crontab entries from a Ruby DSL. The nightly queue builder runs at 2:00 AM UTC (or user-configured timezone offset). Email dispatch is a separate job triggered after queue building.

---

## Testing Stack

### RSpec 3.x + FactoryBot + Capybara + Selenium

- **RSpec**: Unit tests for SM2Engine (pure function, no DB interaction), QueueBuilder, SessionTracker. Integration tests for controllers and models.
- **FactoryBot**: Test data factories for User, Lesson, Exercise, Review, Session, DailyQueue.
- **Capybara + Selenium/Chrome**: Acceptance tests requiring keyboard interaction (keyboard shortcut sequences, focus state verification, timer behavior). Headless Chrome in CI.
- **Mutant**: Per-feature mutation testing after refactoring (CLAUDE.md requirement). Scoped to modified files. Kill rate gate ≥ 80%.

---

## Hosting

### Fly.io

- Container-native (Dockerfile-based deployment)
- PostgreSQL available as managed add-on (`fly postgres`)
- $5-20/month target met: single 256MB RAM app + small PG instance ~$10-15/month
- Rails-friendly: Fly has first-class Rails deployment documentation
- Cron jobs via Fly Machines scheduled tasks or Procfile + Whenever-generated crontab

Railway and Heroku are viable alternatives. Railway's pricing model changed multiple times; Heroku's free tier is gone and base pricing is higher. Fly.io is the most stable option at the target price point.

---

## Dependency Version Constraints

| Dependency | Version | Notes |
|-----------|---------|-------|
| Ruby | 4.0.x | Specify in `.ruby-version` |
| Rails | ~> 8.1 | Pin minor version |
| PostgreSQL adapter | pg ~> 1.5 | PG 16 compatible |
| postmark-rails | ~> 0.22 | ActionMailer adapter |
| solid_queue | Bundled Rails 7.2 | No separate pin needed |
| whenever | ~> 1.0 | Cron scheduler |
| rspec-rails | ~> 6.1 | |
| factory_bot_rails | ~> 6.4 | |
| capybara | ~> 3.39 | |
| selenium-webdriver | ~> 4.x | |
| mutant | ~> 0.11 | Mutation testing |
