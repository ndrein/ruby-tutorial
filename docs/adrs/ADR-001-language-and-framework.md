# ADR-001: Language and Framework — Ruby 4 / Rails 8

**Status**: Accepted
**Date**: 2026-03-09
**Deciders**: Solo developer (user)

---

## Context

Building a personal Ruby syntax learning platform. Language is user-specified: Ruby 4. Framework selection follows from language choice and quality attributes:

- **Maintainability** (rank 1): solo developer extending over months/years
- **Testability** (rank 2): SM-2 algorithm and prerequisite gating must be isolated and tested confidently
- **Time-to-market** (rank 3): personal tool; weeks not months
- **Simplicity** (rank 4): no over-engineering for a 1-user tool

---

## Decision

**Ruby 4 with Rails 8.**

---

## Rationale

Rails 8 is the natural choice for a Ruby web application. It provides:
- Convention-over-configuration: reduces solo developer decisions on routing, ORM, asset pipeline, jobs
- Built-in Hotwire: Turbo + Stimulus included; no separate frontend framework decision needed
- ActiveRecord: ORM for PostgreSQL; reduces persistence boilerplate
- ActiveJob + Sidekiq integration: background job infrastructure for post-MVP email digest
- Mature testing ecosystem: RSpec, FactoryBot, Capybara all battle-tested with Rails

The ports-and-adapters pattern is applied on top of Rails MVC. Domain modules in `app/domain/` have no Rails dependencies. Rails controllers act as primary adapters. This satisfies testability without abandoning Rails conventions.

---

## Alternatives Considered

### Alternative 1: Sinatra + custom infrastructure
- **What**: Minimal Ruby web framework; hand-build ORM adapter, routing, job queue integration
- **Evaluation**: Removes Rails conventions; solo developer must build routing, asset serving, session management from scratch
- **Rejection reason**: Time-to-market impact (rank 3 quality attribute). Rails provides all required capabilities out-of-the-box. Sinatra adds weeks of infrastructure for no benefit given 1 user

### Alternative 2: Hanami 2.x (Ruby, alternative full-stack framework)
- **What**: Modern Ruby framework with built-in ports-and-adapters architecture; cleaner than Rails for DDD
- **Evaluation**: Excellent testability story; Hanami 2 has explicit slices and clean architecture. Smaller community than Rails (GitHub: ~8k stars vs Rails 55k+)
- **Rejection reason**: Smaller ecosystem means fewer examples and gems; solo developer with time constraints benefits from Rails' larger community and documentation surface. Hanami is architecturally superior but the ecosystem gap increases time-to-market risk

### Alternative 3: Pure Ruby (no framework)
- **What**: Write HTTP handling, routing, template rendering without a framework
- **Evaluation**: Maximum control; zero conventions
- **Rejection reason**: Extreme time-to-market impact. No benefit for 1-user tool

---

## Consequences

**Positive**:
- Rails ecosystem fully covers all technical needs: ORM, job queue, frontend, testing
- Large community; well-documented; Rails 8 LTS trajectory
- Convention-over-configuration maximizes solo developer velocity
- Built-in Hotwire eliminates separate frontend framework decision

**Negative**:
- Rails "magic" increases cognitive load for less-experienced Rails developers (not applicable here — builder is learning Ruby, will use Rails as-is)
- ActiveRecord must be excluded from domain layer via ports-and-adapters discipline; requires explicit boundary enforcement (mitigated by RuboCop custom cops)
- Rails 8 is relatively new (2024); some gems may lag behind. Mitigation: stick to well-established gems (Sidekiq, RSpec, FactoryBot)

**License**: MIT (Rails), MIT (Hotwire/Turbo), MIT (Stimulus)
