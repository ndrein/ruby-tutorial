# ADR-005: Prerequisite Gating Model
**Status**: Accepted
**Date**: 2026-03-10

## Context

The platform has 25 lessons in 5 modules. Lessons have prerequisites (FR-8.1 through FR-8.8). `lesson_status` must be derived from SM-2 state — not stored independently (critical constraint from DISCUSS wave, shared-artifacts-registry `lesson_status`).

Key requirements:
- lesson_status is one of: mastered | in_review | new | available | locked
- locked = prerequisites not met
- mastered = SM-2 interval ≥ 30 days
- in_review = SM-2 interval 3-29 days
- new = first pass complete, interval 1-2 days
- available = prerequisites met, no SM-2 record yet
- Status must derive from SM-2 interval data in real time (FR-8.3)
- Locked lessons must show prerequisite list with per-prerequisite completion status (FR-8.4)
- Prerequisite graph is a DAG — no circular dependencies

The question: where is the prerequisite graph stored, and how is completion detected?

## Decision

**Prerequisite graph stored as `INTEGER[]` column on the `lessons` table (`prerequisite_ids`). Completion detection based on presence of any `reviews` record for exercises in the prerequisite lesson.**

`LessonStatusProjector` derives `lesson_status` for all 25 lessons in a single query set:
1. Load all 25 lessons with `prerequisite_ids`
2. Load all user's reviews (or just the SM-2 interval per exercise)
3. For each lesson: check if all prerequisite lesson_ids have at least one review record (completed = ever answered); compute SM-2 interval; derive status

`PrerequisiteChecker` handles the locked-lesson detail view: per-prerequisite completion status and session estimate.

## Consequences

**Positive**:
- No separate `lesson_completions` table required. Completion is inferred from review existence. Single source of truth: `reviews` table.
- `prerequisite_ids` as a PostgreSQL `INTEGER[]` column is lightweight — 5 integers per lesson maximum; no junction table.
- DAG stored in application layer (seed data) — circular dependency detection at seed validation time.
- `LessonStatusProjector` can batch-load all 25 lessons' statuses in ~3 queries (lessons, reviews for user, join) — efficient for curriculum view.
- lesson_status is never stale: computed on every request from current SM-2 state.

**Negative**:
- `prerequisite_ids` as an array column is less queryable than a junction table. Acceptable: the prerequisite graph is static (seed data); application code traverses it, not SQL.
- "Completed" inference from review existence means a user who answered incorrectly on the first and only attempt still counts as having "engaged" with the lesson. Design decision: completion = first review record exists, regardless of correctness. Rationale: the platform does not block progress on incorrect answers; SM-2 will resurface the concept.

## Alternatives Considered

**Separate `lesson_completions` table with explicit `completed_at` field**: Cleaner semantic ("completion" is explicit, not inferred). However, creates a second writer for lesson completion state — both the exercise submission and a lesson-completion trigger would need to write. Risk of divergence between completion state and SM-2 state (exactly the violation the shared-artifacts-registry warns against). Rejected: introduces dual-write risk.

**Prerequisite graph as a separate `lesson_prerequisites` join table**: Standard relational design. More flexible for graph queries. However: the graph is static (seed data, never changes); array column queries are fast for 5 elements; a join table adds a migration and an extra model with no behavioral benefit. Rejected: over-engineered for a static graph of 25 nodes.

**Store `lesson_status` in a materialized column and update via callback**: Would require an ActiveRecord callback on every reviews update to recompute lesson_status. Creates the dual-writer violation explicitly called out in shared-artifacts-registry. Rejected: violates critical constraint.
