# ADR-005: Prerequisite Gating Model

**Status**: Accepted
**Date**: 2026-03-09
**Deciders**: Solo developer (user)

---

## Context

The curriculum consists of 25 lessons across 5 modules with a prerequisite dependency structure. Business rules:
- BR-01: Lesson 1 always available at first launch
- BR-02: A lesson is available iff all its prerequisite lessons are complete
- BR-10: Unlock is atomic with lesson completion (no partial states)
- AC-08-05: Prerequisite graph is acyclic (no cycles)

Decision space: how to model, store, and evaluate the prerequisite graph.

---

## Decision

**Directed Acyclic Graph (DAG) with dual representation: YAML definition file + PostgreSQL `prerequisite_edges` table. Graph loaded into in-memory `PrerequisiteGraph` domain object at boot. Acyclicity validated on load. Prerequisite resolution runs in the domain layer with atomic database commit.**

Specifically:
- `db/curriculum/prerequisites.yml` is the authoritative definition (human-readable, version-controlled)
- Seed task populates `prerequisite_edges` table from YAML on deploy
- `PrerequisiteGraph` loads all edges at boot (25 lessons; negligible memory)
- `LessonUnlocker` domain service evaluates which lessons to unlock after a completion, using in-memory graph + persisted progress state from `LessonRepository` port
- Lesson completion + prerequisite unlock execute in a single PostgreSQL transaction via `LessonRepository` port

---

## Rationale

**YAML source + DB table** separation provides:
- Human-readable curriculum definition that can be edited without SQL
- PostgreSQL foreign-key integrity for runtime data
- CI validation of acyclicity from YAML before deploy

**In-memory PrerequisiteGraph** provides:
- Fast traversal (25 nodes; no DB query for each lesson render)
- Isolated testability: load from YAML fixture without DB
- Acyclicity check on boot (application fails to start with a cyclic graph — fail-fast)

**Atomic unlock transaction** provides:
- BR-10: no intermediate states where lesson is complete but successors are not yet evaluated
- Satisfies AC-08-03 (lesson unlock visible on lesson-complete screen without refresh)

---

## Alternatives Considered

### Alternative 1: Module-only prerequisite gates (no per-lesson prerequisites)
- **What**: A lesson is available iff its module is the current module (i.e., all prior modules are complete). No per-lesson edges.
- **Evaluation**: Simpler model; eliminates DAG complexity. Module N unlocks when all lessons in Module N-1 are complete.
- **Rejection reason**: Requirements explicitly specify per-lesson prerequisites (US-08: "L10 requires L8 and L9"). Multi-prerequisite lessons exist within a module. Module-only gating does not match the curriculum design. Rejected by requirements.

### Alternative 2: Prerequisite edges stored only in YAML (no DB table)
- **What**: `PrerequisiteGraph` loads from YAML at request time (or cached). No `prerequisite_edges` DB table.
- **Evaluation**: Simpler schema; one fewer table; YAML is authoritative at runtime.
- **Rejection reason**: Without DB representation, cannot query "all lessons this user is eligible to unlock" in a single SQL query. DB table enables future analytics (e.g., "which prerequisites block the most users"). DB representation also enables foreign-key validation against lesson IDs. Seed from YAML is a one-time cost; table adds integrity.

### Alternative 3: Procedural completion check on every lesson load (no in-memory graph)
- **What**: On each lesson view, query `prerequisite_edges` and `lesson_progress` to compute lock state in real time
- **Evaluation**: No in-memory graph needed; DB is source of truth at all times
- **Rejection reason**: 25 lessons; graph is static (never changes at runtime). Loading into memory at boot is correct. Per-request graph queries add latency for no benefit. In-memory graph is simpler and faster.

---

## Consequences

**Positive**:
- `PrerequisiteGraph` is testable with YAML fixture; no DB required for unit tests
- Acyclicity validated at boot: deployment fails if content author introduces a cycle
- YAML definition is human-readable; curriculum maintainer edits prerequisites without SQL
- Atomic unlock transaction prevents any intermediate ambiguous lesson state

**Negative**:
- Boot-time graph load: if curriculum grows beyond 25 lessons significantly, memory impact increases. For 25 lessons, this is negligible. Mitigation: document that `PrerequisiteGraph` is boot-cached; reload via app restart on curriculum changes.
- YAML and DB table must stay in sync: seed must be re-run after curriculum changes. Mitigation: deploy checklist item; CI check validates YAML → DB sync.

**Acyclicity guarantee**:
- `PrerequisiteGraph#load` performs DFS cycle detection on startup.
- Application raises `PrerequisiteGraph::CyclicDependencyError` and refuses to start if cycle detected.
- CI runs acyclicity check against YAML before merge.
