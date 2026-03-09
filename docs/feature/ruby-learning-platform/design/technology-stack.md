# Technology Stack — Ruby Learning Platform

**Date**: 2026-03-09
**Paradigm**: Object-Oriented

All technology choices follow OSS-first policy. No proprietary software without explicit user request.

---

## Core Stack

| Layer | Technology | Version | License | Rationale |
|-------|-----------|---------|---------|-----------|
| Language | Ruby | 4.x | BSD-2-Clause | User-specified; learning Ruby in Ruby reinforces the domain |
| Web Framework | Rails | 8.x | MIT | Standard Ruby web framework; convention-over-configuration reduces solo dev overhead; built-in Turbo/Hotwire support |
| Database | PostgreSQL | 17 | PostgreSQL License (OSS) | Relational data with complex queries; ACID guarantees for SM-2 atomic updates; excellent Rails integration |
| ORM | ActiveRecord | (bundled with Rails) | MIT | Rails-native; reduces boilerplate for a solo project |
| Frontend | Hotwire (Turbo + Stimulus) | Turbo 2.x / Stimulus 3.x | MIT | Rails-native; server-rendered; no separate frontend build; Stimulus enables keyboard shortcut controllers without heavy JS framework |
| Background Jobs | Sidekiq | 7.x | LGPL-3.0 | Industry standard; simple Redis-backed queue; post-MVP email digests |
| Job Queue / Cache | Redis | 7.x | BSD-3-Clause | Session plan cache (BR-12); Sidekiq backing store |
| App Server | Puma | 6.x | BSD-3-Clause | Rails default; multi-threaded; sufficient for 1 user |

---

## Testing Stack

| Tool | Version | License | Purpose |
|------|---------|---------|---------|
| RSpec | 3.x | MIT | Primary test framework; BDD-style specs align with user story AC |
| FactoryBot | 6.x | MIT | Test fixtures for ActiveRecord models |
| Capybara | 3.x | MIT | Integration/system tests; verifies keyboard navigation flows |
| SimpleCov | 0.22+ | MIT | Coverage reporting; CI gate |

---

## Development Tooling

| Tool | Version | License | Purpose |
|------|---------|---------|---------|
| RuboCop | 1.x | MIT | Code style enforcement; custom cops for module boundary violations |
| Brakeman | 6.x | MIT | Static security analysis for Rails |
| Bundler | 2.x | MIT | Dependency management |

---

## Infrastructure (Self-Hosted PaaS)

| Component | Option A | Option B | Option C |
|-----------|---------|---------|---------|
| Platform | Heroku | Railway | Fly.io |
| PostgreSQL | Heroku Postgres | Railway PostgreSQL | Fly.io Postgres |
| Redis | Heroku Redis | Railway Redis | Upstash Redis |
| Target cost | ~$15/month | ~$10/month | ~$10/month |

All three are OSS-compatible managed platforms. Choice is deployment-time decision, not architecture decision. Architecture is platform-agnostic.

---

## Post-MVP: Email Service

| Option | License | Notes |
|--------|---------|-------|
| Mailgun | Proprietary (free tier available) | 1,000 emails/month free; adequate for 1 user |
| SendGrid | Proprietary (free tier available) | Alternative if Mailgun unavailable |
| SMTP (self-hosted) | N/A | Option for full control; more ops overhead |

Email service is post-MVP. Architecture includes adapter port; implementation deferred.

---

## Rejected Technologies

| Technology | Reason Rejected |
|-----------|----------------|
| React / Vue / Angular | Unnecessary for single-user keyboard-native tool; adds build complexity; no client-side state management requirement that Stimulus cannot handle |
| MongoDB | No document-store requirement; relational data (exercises, prerequisites, SM-2 intervals) better served by PostgreSQL with foreign keys |
| SQLite | Insufficient concurrency guarantees for production; no managed cloud offering; PostgreSQL upgrade path cleaner |
| GraphQL | Single client (browser); no mobile bandwidth concern; no nested query requirement; REST + Turbo simpler |
| Kubernetes | 1 user; container orchestration overhead unjustified; PaaS handles deployment entirely |
| Sinatra | Lacks built-in ORM, job queue, asset pipeline conventions; Rails provides all needed batteries for solo dev productivity |

---

## OSS Health Assessment (Critical Components)

| Component | Last Release | Stars | License | Health |
|-----------|-------------|-------|---------|--------|
| Rails | Active (8.x, 2024–2025) | 55k+ | MIT | Excellent |
| Hotwire/Turbo | Active (2.x, 2024) | 6k+ | MIT | Excellent |
| Stimulus | Active (3.x, 2024) | 12k+ | MIT | Excellent |
| RSpec | Active (3.x, 2024) | 5k+ | MIT | Excellent |
| Sidekiq | Active (7.x, 2025) | 13k+ | LGPL-3.0 | Excellent |
| PostgreSQL | Active (17, 2024) | — | OSS License | Excellent |
