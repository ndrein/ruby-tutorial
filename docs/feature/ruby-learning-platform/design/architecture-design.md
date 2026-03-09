# Architecture Design — Ruby Learning Platform

**Feature**: ruby-learning-platform
**Date**: 2026-03-09
**Status**: Approved
**Paradigm**: Object-Oriented (Ruby 4)

---

## System Context

A single-user personal web application for learning Ruby syntax via SM-2 spaced repetition. No external auth. No multi-tenancy. Deployment target: self-hosted PaaS (Heroku/Railway/Fly.io) at $5–20/month.

### Quality Attributes (Priority Order)

| Rank | Attribute | Driver |
|------|-----------|--------|
| 1 | Maintainability | Solo developer; years-long extension horizon |
| 2 | Testability | SM-2 algorithm and prerequisite gating are correctness-critical |
| 3 | Time-to-market | Personal tool; weeks not months |
| 4 | Simplicity | Solo dev economics; no over-engineering |
| 5 | Keyboard usability | Developer-grade UI requirement |

---

## C4 System Context (Level 1)

```mermaid
C4Context
    title Ruby Learning Platform — System Context

    Person(user, "Ana Folau", "Solo learner. Senior Python/Java developer learning Ruby.")

    System(platform, "Ruby Learning Platform", "Web app delivering SM-2 spaced repetition over a 25-lesson Ruby curriculum. Keyboard-native. 15-minute daily sessions.")

    System_Ext(email_svc, "Email Service (Post-MVP)", "Sends daily session reminders. Mailgun or SendGrid. Not required for MVP.")

    Rel(user, platform, "Opens daily session, completes exercises, reviews progress", "HTTPS / Browser")
    Rel(platform, email_svc, "Sends daily review summary", "SMTP / HTTP API (post-MVP)")
```

---

## C4 Container Diagram (Level 2)

```mermaid
C4Container
    title Ruby Learning Platform — Containers

    Person(user, "Ana Folau", "Solo learner")

    Container(browser, "Browser", "Hotwire/Turbo + Stimulus", "Renders UI. Handles keyboard shortcuts via Stimulus controllers. Streams server updates via Turbo Streams.")

    Container(rails_app, "Rails Web Application", "Ruby 4 / Rails 8", "Serves all HTTP requests. Contains domain logic via ports-and-adapters. Renders Turbo-compatible HTML responses.")

    ContainerDb(postgres, "PostgreSQL 17", "PostgreSQL", "Stores lessons, exercises, SM-2 review state, session logs, prerequisite graph, and user progress.")

    Container(job_worker, "Background Job Worker", "Sidekiq + Redis", "Processes async jobs. Post-MVP: daily email digest. MVP: deferred exercise carry-over computation if needed.")

    ContainerDb(redis, "Redis", "Redis", "Sidekiq job queue. Session cache for pre-computed daily plan (BR-12).")

    System_Ext(email_svc, "Email Service (Post-MVP)", "Mailgun / SendGrid")

    Rel(user, browser, "Navigates, submits answers, uses keyboard shortcuts", "HTTPS")
    Rel(browser, rails_app, "HTTP requests, Turbo Stream subscriptions", "HTTPS / Turbo")
    Rel(rails_app, postgres, "Reads/writes domain state", "SQL / ActiveRecord")
    Rel(rails_app, redis, "Caches session plan; enqueues background jobs", "Redis protocol")
    Rel(job_worker, postgres, "Reads SM-2 data for email digest", "SQL / ActiveRecord")
    Rel(job_worker, email_svc, "Sends daily digest email", "SMTP / HTTP API (post-MVP)")
    Rel(job_worker, redis, "Reads job queue", "Redis protocol")
```

---

## C4 Component Diagram — SM-2 Engine (Level 3)

The SM-2 engine has 5+ internal components and is correctness-critical. Component diagram mandatory.

```mermaid
C4Component
    title SM-2 Engine — Components (within Rails Web Application)

    Container_Boundary(rails_app, "Rails Web Application") {
        Component(review_queue, "ReviewQueue", "Domain Service", "Computes today's due exercises (next_review_date <= today). Applies daily cap (max 12 / 6 min). Sorts by urgency (most overdue first). Handles deferred carry-over.")

        Component(sm2_algorithm, "SM2Algorithm", "Domain Service (Pure)", "Stateless SM-2 computation. Inputs: current_interval, ease_factor, result. Outputs: new_interval, new_ease_factor, new_next_review_date. No side effects.")

        Component(review_scheduler, "ReviewScheduler", "Application Service", "Orchestrates exercise result recording. Calls SM2Algorithm to compute new state. Persists update via ReviewRepository port. Enforces atomic update per exercise.")

        Component(session_planner, "SessionPlanner", "Application Service", "Computes and caches daily session plan on session open (BR-12). Coordinates ReviewQueue + LessonUnlocker to produce review_count + next_lesson.")

        Component(review_repo_port, "ReviewRepository (Port)", "Driven Port", "Interface for SM-2 state persistence. Implementations: ActiveRecord adapter (PostgreSQL). Enables isolated unit testing via mock adapter.")

        Component(review_repo_adapter, "ActiveRecord ReviewRepository", "Driven Adapter", "PostgreSQL implementation of ReviewRepository port. Reads/writes exercises, review_logs tables via ActiveRecord.")
    }

    Rel(session_planner, review_queue, "Requests today's due exercises", "method call")
    Rel(review_queue, review_repo_port, "Queries exercises by next_review_date", "port call")
    Rel(review_scheduler, sm2_algorithm, "Computes new SM-2 state", "method call")
    Rel(review_scheduler, review_repo_port, "Persists updated exercise state", "port call")
    Rel(review_repo_port, review_repo_adapter, "Implemented by", "adapter")
```

---

## C4 Component Diagram — Lesson Tree (Level 3)

```mermaid
C4Component
    title Lesson Tree — Components (within Rails Web Application)

    Container_Boundary(rails_app, "Rails Web Application") {
        Component(curriculum_map, "CurriculumMap", "Domain Service", "Provides the full 25-lesson curriculum with per-lesson status (complete/available/locked) for the current user's progress state.")

        Component(prerequisite_graph, "PrerequisiteGraph", "Domain Model", "DAG of lesson prerequisite edges. Loaded from db/curriculum/prerequisites.yml at boot. Validates acyclicity on load. Exposes: prerequisites_for(lesson_id), is_acyclic?")

        Component(lesson_unlocker, "LessonUnlocker", "Domain Service", "Determines available lessons given current progress. Runs atomically with lesson completion (BR-10). Produces unlock events for newly available lessons.")

        Component(lesson_repo_port, "LessonRepository (Port)", "Driven Port", "Interface for lesson and progress state persistence. Enables test isolation.")

        Component(lesson_repo_adapter, "ActiveRecord LessonRepository", "Driven Adapter", "PostgreSQL implementation. Reads lessons, modules, prerequisite_edges, user_progress tables.")

        Component(lock_screen_policy, "LockScreenPolicy", "Domain Service", "Resolves lock screen content: why a lesson is locked, target lesson topics, prerequisite lesson topics, which prerequisites are complete.")
    }

    Rel(curriculum_map, prerequisite_graph, "Reads prerequisite structure", "method call")
    Rel(curriculum_map, lesson_repo_port, "Reads lesson progress", "port call")
    Rel(lesson_unlocker, prerequisite_graph, "Evaluates unlock conditions", "method call")
    Rel(lesson_unlocker, lesson_repo_port, "Reads/writes progress state", "port call")
    Rel(lock_screen_policy, prerequisite_graph, "Resolves prerequisite chain", "method call")
    Rel(lock_screen_policy, lesson_repo_port, "Reads per-prerequisite completion", "port call")
    Rel(lesson_repo_port, lesson_repo_adapter, "Implemented by", "adapter")
```

---

## Architectural Style

**Modular monolith with ports-and-adapters (hexagonal).**

All domain logic lives in the Rails app, isolated from infrastructure via port interfaces. Rails MVC provides the web delivery layer (primary adapter). ActiveRecord adapters implement driven ports. Turbo/Stimulus handle browser-side interactivity without a separate frontend build.

### Rationale

- Solo developer: modular monolith eliminates distributed systems operational overhead.
- Testability #2 priority: ports-and-adapters enables full isolation of SM-2Algorithm and PrerequisiteGraph — the correctness-critical components — without database.
- Rails conventions reduce boilerplate; well-understood for solo Ruby projects.
- Hotwire eliminates need for a separate JavaScript frontend while supporting keyboard-native interaction via Stimulus.

### Rejected Alternatives

**Alternative 1: Layered MVC without ports-and-adapters**
- What: Standard Rails MVC, no explicit port interfaces; controllers call ActiveRecord directly.
- Expected Impact: Faster initial setup; no interface definitions needed.
- Why Insufficient: SM-2 algorithm and prerequisite gating would be tightly coupled to ActiveRecord; unit testing requires DB fixtures or complex stubs. Testability (priority #2) unmet.

**Alternative 2: Microservices (SM-2 as separate service)**
- What: SM-2 engine as standalone HTTP service; Rails app calls it over HTTP.
- Expected Impact: Independent deployability of SM-2 engine.
- Why Insufficient: Solo developer; one user. Distributed systems overhead (service discovery, HTTP contracts, separate deploys) not justified. Adds weeks of infrastructure work. Time-to-market (priority #3) severely impacted.

---

## Module Boundaries

The Rails application is organized into bounded modules with explicit dependency rules. Dependencies flow inward only (toward domain).

```
app/
  domain/
    sm2/              # SM-2 engine: algorithm, review queue, scheduler
    curriculum/       # Lesson tree, prerequisite graph, lesson unlocker
    session/          # Session planner, session state, daily plan
    progress/         # Progress tracker, retention calculator, streak
    exercise/         # Exercise types, answer evaluation, hint policy
  adapters/
    repositories/     # ActiveRecord implementations of driven ports
    web/              # Turbo/Rails controllers (primary adapters)
  ports/
    review_repository.rb
    lesson_repository.rb
    session_repository.rb
    progress_repository.rb
```

**Dependency rules:**
- `domain/` has zero Rails/ActiveRecord dependencies.
- `adapters/repositories/` depends on `domain/` ports, never on other adapters.
- `adapters/web/` depends on domain application services, never on repositories directly.
- Cross-domain calls go through application services only (no cross-domain repository access).

---

## Integration Patterns

### Browser → Rails App
- Turbo Drive for standard page navigation (no full-page reload).
- Turbo Frames for exercise submission feedback (renders new state without page reload; meets 100ms feedback requirement).
- Stimulus controllers handle keyboard shortcut registration, timer countdown, focus management.
- No separate API layer; Rails renders HTML responses consumed by Turbo.

### SM-2 State Persistence (Mid-Session Durability)
- BR-12: session plan cached in Redis on session open (key: `session_plan:{session_id}`).
- Each exercise result persisted immediately (not batched) to PostgreSQL — ensures SM-2 state survives browser refresh (AC-05-06).
- Session record marked complete atomically after all exercises persist.

### Prerequisite Unlock (Atomicity)
- Lesson completion and prerequisite resolver run inside a single database transaction.
- No intermediate state where lesson is complete but successors are not evaluated.
- Satisfies BR-10 and AC-08-03.

### Background Jobs (Post-MVP)
- Sidekiq with Redis queue.
- Daily digest job: queries SM-2 due exercises for next day; sends via email service adapter.
- MVP: Sidekiq infrastructure included but no active jobs.

---

## Quality Attribute Strategies

### Maintainability
- Ports-and-adapters: swap infrastructure (DB, email provider) without touching domain logic.
- Module boundaries enforced by directory structure and RuboCop custom cops.
- All 25 lessons + 75 exercises in structured YAML (`db/curriculum/`); content changes require no code changes.
- Curriculum schema versioned; content authoring separated from code authoring.

### Testability
- SM-2Algorithm: pure function, no dependencies, testable with plain RSpec examples.
- PrerequisiteGraph: in-memory DAG, no DB; testable with YAML fixture.
- Domain services tested through port interfaces using in-memory test adapters.
- No ActiveRecord in domain layer = no DB required for unit tests.

### Performance
- Session dashboard 500ms target: session plan pre-computed and cached in Redis on open.
- SM-2 queue 200ms target: PostgreSQL index on `exercises.next_review_date`; query returns max 12 rows.
- Curriculum tree 300ms target: 25 lessons is trivial; single query with eager-loaded modules.
- Exercise feedback 100ms target: Turbo Frame partial re-render; no full page reload.

### Reliability
- SM-2 state durability: exercise results persisted per-exercise, not batched at session end.
- Lesson completion atomicity: database transaction wraps completion + prerequisite unlock.
- Esc mid-lesson saves position: exercise position stored in session_state table before navigation.

### Keyboard Usability
- Stimulus controllers: single keymap config file; all shortcuts registered globally.
- Focus management: after overlay close, focus returns to triggering element (AC-07 compliance).
- No action >3 keypresses from any screen (audited per user story).

---

## Deployment Architecture

Single Heroku/Railway/Fly.io dyno (or equivalent):
- Web process: Puma (multi-threaded; 2-4 threads sufficient for 1 user).
- Worker process: Sidekiq (1 worker; post-MVP only).
- PostgreSQL: managed add-on (Heroku Postgres Hobby / Railway PostgreSQL / Fly.io Postgres).
- Redis: managed add-on (Heroku Redis / Railway Redis / Fly.io Redis).
- Target cost: $5–20/month.

No CDN required (single user, no static asset scale concern). HTTPS via PaaS TLS termination.

---

## Security

Single-user personal tool with no authentication requirement. Rails built-in protections apply:
- **CSRF**: Rails `protect_from_forgery` active by default on all POST/PATCH/DELETE routes
- **XSS**: ERB auto-escapes all user-facing output; no raw HTML rendering of user input
- **SQL injection**: ActiveRecord parameterized queries; no string-interpolated SQL in adapters
- **Dependency scanning**: Brakeman (static analysis) in development toolchain; `bundler-audit` for known CVEs

No user-generated content stored beyond exercise answers (which are never re-rendered as HTML). Authentication not in scope; no session auth attack surface.

---

## ADR Index

| ADR | Decision |
|-----|---------|
| ADR-001 | Language and Framework: Ruby 4 / Rails 8 |
| ADR-002 | Database: PostgreSQL 17 |
| ADR-003 | Frontend Approach: Hotwire (Turbo + Stimulus) |
| ADR-004 | SM-2 Implementation Strategy |
| ADR-005 | Prerequisite Gating Model |
