# ADR-001: Language and Framework Selection
**Status**: Accepted
**Date**: 2026-03-10

## Context

A personal Ruby syntax learning platform for an experienced developer (Python/Java background). Single user, hosted at $5-20/month, requires: SM-2 spaced repetition, daily email, keyboard-native UI, progress dashboard, session cap enforcement. Builder = user. Team size: 1.

Quality attribute priorities (from DISCOVER/DISCUSS):
1. Maintainability — builder maintains alone; must understand every line
2. Time-to-market — personal tool; value delivered when usable
3. Testability — SM-2 purity is a product invariant, not an engineering preference
4. Operational simplicity — no DevOps specialist; Fly.io one-command deploy

## Decision

**Ruby 4.0 on Rails 8.1.**

## Consequences

**Positive**:
- The platform teaches Ruby. Building it in Ruby means the builder reads and writes idiomatic Ruby daily during development — content calibration improves through dogfooding.
- Rails 7.2 provides ActiveRecord (ORM), Action Mailer (email), Solid Queue (background jobs), Hotwire (frontend), and Propshaft (assets) — all required capabilities, zero assembly required.
- Rails convention-over-configuration reduces decision fatigue for a solo developer.
- Ruby's expressiveness allows SM2Engine to be a clean pure function without ceremony.
- RSpec is idiomatic for Ruby; mutation testing via Mutant has first-class Ruby support.

**Negative**:
- Ruby is not the fastest runtime. Not relevant at single-user load.
- Rails' "magic" can obscure behavior. Mitigated by explicit dependency inversion in service objects.

## Alternatives Considered

**Sinatra + custom assembly**: Ruby but without Rails batteries. Would require manually assembling ORM, mailer, job queue, asset pipeline. No gain for a solo project with well-defined requirements. Rejected: additional assembly cost, no benefit.

**Python + Django**: Builder knows Python well; onboarding would be fast. However, building the Ruby learning platform in a different language removes the dogfooding benefit — the builder would not practice Ruby syntax during development. Rejected: misaligns with the product's learning purpose.

**Node.js + Express**: Fast startup, familiar to some JS developers. Not the builder's primary language. No ecosystem advantage over Rails for this feature set. Rejected: no advantage; increases tooling complexity (separate frontend/backend paradigms).
