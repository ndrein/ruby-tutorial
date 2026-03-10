# ADR-002: Database Selection
**Status**: Accepted
**Date**: 2026-03-10

## Context

Data model is relational: users, lessons (static), exercises (static), reviews (SM-2 state per user+exercise), sessions, daily_queues. Key query patterns:
- SM-2 queue: `WHERE next_review_date <= today ORDER BY next_review_date` — index-friendly range query
- Lesson status derivation: JOIN reviews + exercises + lessons
- Streak calculation: COUNT sessions WHERE session_date = today

Single user. No read replicas needed. Hosting on Fly.io ($5-20/month budget). Must support: array columns (exercise_ids, prerequisite_ids, accepted_synonyms), DECIMAL precision (ease_factor), TIMESTAMPTZ, CHECK constraints.

## Decision

**PostgreSQL 16** via Fly.io managed Postgres (`fly postgres create`).

## Consequences

**Positive**:
- Native array columns (`INTEGER[]`, `TEXT[]`) eliminate separate junction tables for `prerequisite_ids` and `exercise_ids` — simplifies schema for static seed data.
- `DECIMAL(4,2)` for ease_factor provides correct precision without floating-point drift.
- `ON CONFLICT DO UPDATE` (upsert) is first-class — essential for daily_queues idempotency.
- `gen_random_uuid()` for user PKs without a separate UUID extension.
- `TIMESTAMPTZ` ensures timezone-correct session duration calculations.
- `SELECT FOR UPDATE` available if concurrent write protection ever needed.
- Fly.io Postgres add-on: managed backups, HA option, $7-15/month for small instance.
- Zero license cost (PostgreSQL License is OSS).

**Negative**:
- PostgreSQL is heavier than SQLite. Not a problem at single-user scale; relevant only if memory is extremely constrained (256MB Fly.io instance is sufficient).
- Requires running as a separate service (vs. SQLite embedded). Fly.io managed Postgres handles this transparently.

## Alternatives Considered

**SQLite**: Zero-ops, single file, embedded. Sufficient for single-user traffic. However: no native array columns (would need JSON workaround for exercise_ids/prerequisite_ids), no `ON CONFLICT DO UPDATE` for idempotent upserts (SQLite has `INSERT OR REPLACE` but different semantics), no `TIMESTAMPTZ`, and Rails + Solid Queue have better battle-tested integrations with PostgreSQL. Rejected: schema ergonomics and production reliability favor PostgreSQL.

**MySQL 8**: Viable alternative to PostgreSQL. Weaker native array support (no `INTEGER[]`; would use JSON). `ON CONFLICT` syntax differs (requires `INSERT ... ON DUPLICATE KEY UPDATE`). No significant advantage over PostgreSQL. Rejected: PostgreSQL is the Rails community's dominant choice; better tooling and documentation for this stack.

**MongoDB**: Document store. No relational requirements; SM-2 data is highly relational (user → exercises → reviews with interval queries). Rejected: no benefit; significant complexity increase for range queries on next_review_date.
