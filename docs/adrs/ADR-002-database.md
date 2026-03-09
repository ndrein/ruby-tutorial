# ADR-002: Database — PostgreSQL 17

**Status**: Accepted
**Date**: 2026-03-09
**Deciders**: Solo developer (user)

---

## Context

The Ruby Learning Platform requires durable storage for:
- Lesson curriculum and exercise content (structured, relational)
- SM-2 review state: ease_factor, interval, next_review_date per exercise (atomic updates required)
- Review logs: append-only record of every exercise result (correctness-critical, never modified)
- Lesson progress and prerequisite unlock state (atomic: completion + unlock in one transaction)
- Session records and streak tracking

Key data requirements:
- **ACID transactions**: lesson completion + prerequisite unlock must be atomic (BR-10)
- **Relational queries**: review logs joined to exercises joined to lessons for retention scores
- **Date-based queries**: exercises where next_review_date <= today (SM-2 daily queue)
- **Single user**: no concurrency, sharding, or replication requirements
- **Managed hosting**: self-hosted PaaS at $5–20/month

---

## Decision

**PostgreSQL 17.**

---

## Rationale

PostgreSQL is the default relational database for Rails applications in 2025. It provides:
- Full ACID transactions: lesson completion + prerequisite unlock atomic (critical requirement)
- `date` type and date comparisons: efficient SM-2 queue queries (`WHERE next_review_date <= $1`)
- `text[]` arrays: efficient storage of topics_covered/topics_not_covered without join tables
- `jsonb`: multiple-choice options stored inline without additional tables
- `decimal(4,2)`: precise ease_factor storage
- Managed cloud options on all three target PaaS platforms (Heroku, Railway, Fly.io)
- Rails/ActiveRecord native support; migration tooling mature

---

## Alternatives Considered

### Alternative 1: SQLite
- **What**: Embedded relational database; zero infrastructure; file-based
- **Evaluation**: Sufficient for 1 user; Rails 8 supports SQLite in production mode (new in 8.x). No network overhead. Good ACID guarantees for single-writer scenarios.
- **Rejection reason**: SQLite has limited support on PaaS platforms (ephemeral filesystem on Heroku; Railway SQLite is non-trivial). Managed cloud PostgreSQL is available at equivalent price. Migrating from SQLite to PostgreSQL later is a non-trivial effort. Start with production-grade DB.

### Alternative 2: MySQL 8
- **What**: Widely used relational DB; strong Rails support
- **Evaluation**: Viable. Rails supports MySQL natively. JSON support added in MySQL 8.
- **Rejection reason**: PostgreSQL has superior `jsonb` indexing, native `text[]` arrays, and stronger standards compliance. No compelling advantage over PostgreSQL for this project. Community/documentation skews PostgreSQL for Rails in 2025.

### Alternative 3: MongoDB
- **What**: Document store; schema-flexible
- **Evaluation**: Flexible schema useful for highly variable document structures
- **Rejection reason**: Data is fundamentally relational (exercises belong to lessons, review_logs reference exercises, prerequisites are edges between lessons). Document store provides no benefit; foreign key constraints and join queries would require manual enforcement. Wrong tool for the data model.

---

## Consequences

**Positive**:
- ACID transaction guarantees satisfy BR-10 (atomic lesson completion + unlock)
- `next_review_date` index makes SM-2 queue query O(log n); meets 200ms target
- Managed add-on on all target PaaS platforms; zero ops overhead
- Rails migration tooling mature and well-documented
- Append-only review_logs table enables retention score recalculation from source data

**Negative**:
- Requires a running PostgreSQL server (cannot run purely on-machine with zero infrastructure). Mitigation: PaaS managed add-on; developer sets up once
- Connection pooling required for production (Puma + ActiveRecord). Mitigation: Rails connection pool configured at 5 connections; more than sufficient for 1 user

**License**: PostgreSQL License (OSS-compatible, permissive)
**GitHub**: https://github.com/postgres/postgres — actively maintained
