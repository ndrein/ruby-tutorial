# ADR-004: SM-2 Implementation Strategy

**Status**: Accepted
**Date**: 2026-03-09
**Deciders**: Solo developer (user)

---

## Context

The SM-2 algorithm is the core correctness-critical domain of this platform. Incorrect SM-2 implementation directly degrades learning outcomes — the primary purpose of the tool. Quality attributes driving this decision:

- **Testability** (rank 2): SM-2 algorithm and queue computation must be confidently tested in isolation
- **Maintainability** (rank 1): SM-2 rules may be refined post-MVP based on observed learning patterns

SM-2 algorithm rules (from requirements BR-07, BR-08, BR-09):
- Correct: `new_interval = max(1, prev_interval * ease_factor)`
- Incorrect: `new_interval = 1`, `ease_factor -= 0.2` (min 1.3)
- Skipped: re-queue next session; ease_factor unchanged
- Missed (timer): treated as incorrect
- Daily queue: exercises where `next_review_date <= today`
- Daily cap: max(12 exercises, 6 minutes); deferred exercises carry to next session as high-priority

Decision space: how to implement SM-2 within the architecture.

---

## Decision

**Pure domain service with ports-and-adapters isolation.**

`SM2Algorithm` is a stateless pure service: takes current state + result, returns new state. No database access. No Rails dependencies. `ReviewScheduler` is the application service that orchestrates the algorithm call and persists state via `ReviewRepository` port. `ReviewQueue` is a domain service that computes today's queue from persisted state via the same port.

SM-2 state is persisted to PostgreSQL (`review_states` table) per exercise. Each exercise result is persisted immediately — not batched at session end — to satisfy durability requirement (AC-05-06: survives browser refresh).

---

## Rationale

The pure-service approach provides:
1. `SM2Algorithm` unit-testable with zero setup (no DB, no Rails boot). Tests specify input → output directly.
2. `ReviewQueue` testable with in-memory test adapter for `ReviewRepository`.
3. Exact SM-2 rules encoded as assertions in tests, not integration tests against a DB fixture.
4. Algorithm can be modified (e.g., adjusted ease_factor decay) without touching persistence code.

Immediate per-exercise persistence (not batch) satisfies BR-12 and AC-05-06: refreshing mid-session does not lose completed exercise results. The trade-off is slightly more DB writes; acceptable for 1 user.

---

## Alternatives Considered

### Alternative 1: Embed SM-2 logic in ActiveRecord model (Exercise model)
- **What**: `Exercise#update_after_review(result)` calls SM-2 math inline and calls `self.save`. SM-2 logic in the model.
- **Evaluation**: Common Rails pattern; minimal ceremony; no extra classes
- **Rejection reason**: SM-2 algorithm becomes coupled to ActiveRecord lifecycle. Unit testing requires DB. Violates testability requirement (rank 2). Model becomes a "fat model" — difficult to maintain as algorithm rules evolve. Rejected.

### Alternative 2: Use existing SM-2 gem (e.g., `srs` gem)
- **What**: Delegate SM-2 computation to a Ruby gem that implements the algorithm
- **Evaluation**: Reduces algorithm authoring effort; well-tested externally
- **Rejection reason**: Available Ruby SM-2 gems (as of 2025) are small, sparsely maintained, and implement slightly different SM-2 variants. The SM-2 rules for this platform are explicitly specified (BR-07–BR-09) and are ~15 lines of logic. Wrapping an external gem around a 15-line algorithm adds a dependency that may drift. Implement as a first-class domain service; test explicitly. Simpler, more maintainable.

### Alternative 3: Session-end batch persistence
- **What**: Hold SM-2 updates in memory during session; commit all at session complete
- **Evaluation**: Fewer DB writes; cleaner transaction boundary
- **Rejection reason**: Violates AC-05-06: SM-2 state must survive browser refresh before session completes. Batch-at-end means a tab crash loses the entire session's SM-2 updates. Immediate-per-exercise persistence is required.

---

## Consequences

**Positive**:
- SM-2Algorithm unit tests run in milliseconds with no DB or Rails dependencies
- ReviewQueue tested with in-memory adapter; no DB fixtures needed
- SM-2 rules are explicit, auditable, and independently versioned
- Immediate persistence ensures durability across browser crashes

**Negative**:
- Adds `SM2Algorithm`, `ReviewScheduler`, `ReviewQueue` classes vs. inline model methods — more files, more classes. Acceptable: complexity is domain-appropriate, not infrastructure complexity
- ReviewScheduler must handle the case where persistence fails mid-update. Mitigation: each exercise update is a single-row UPDATE in a transaction; failure leaves prior state intact (exercise just doesn't advance — it will re-appear in next queue)

**Testing strategy note** (for software-crafter):
- `SM2Algorithm` spec: table-driven tests for all result types including edge cases (ease_factor at minimum, interval at 1)
- `ReviewQueue` spec: in-memory adapter seeded with fixture exercises; verify queue order, cap enforcement, deferred handling
- `ReviewScheduler` spec: verify it calls SM2Algorithm correctly and delegates persistence to port
