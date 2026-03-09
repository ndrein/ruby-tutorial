# Component Boundaries — Ruby Learning Platform

**Date**: 2026-03-09
**Architecture**: Modular monolith, ports-and-adapters

---

## Boundary Principles

1. **Domain modules have zero Rails/ActiveRecord dependencies.**
2. **Adapters depend on domain ports; domain never depends on adapters.**
3. **Cross-domain communication goes through application services only.**
4. **Each domain module owns one bounded context: its data, its rules, its ports.**

---

## Module Map

```
app/
├── domain/
│   ├── sm2/                    # SM-2 bounded context
│   ├── curriculum/             # Lesson tree + prerequisite gating
│   ├── session/                # Session planning + state
│   ├── progress/               # Progress tracking + dashboard data
│   └── exercise/               # Exercise types + answer evaluation
├── ports/                      # Driven port interfaces (Ruby modules/abstract classes)
│   ├── review_repository.rb
│   ├── lesson_repository.rb
│   ├── session_repository.rb
│   └── progress_repository.rb
├── adapters/
│   ├── repositories/           # ActiveRecord driven adapters
│   └── web/                    # Rails controllers + Turbo views (primary adapters)
db/
└── curriculum/
    ├── lessons.yml             # 25 lessons + exercises content
    └── prerequisites.yml       # Prerequisite DAG definition
config/
└── onboarding.yml              # Assumed-knowledge list (US-01)
```

---

## Domain Module: sm2

**Bounded context**: SM-2 algorithm execution and review scheduling.

**Owns**:
- `SM2Algorithm` — pure stateless computation of new interval/ease_factor given result type
- `ReviewQueue` — selects and orders today's due exercises; applies daily cap; handles deferred carry-over
- `ReviewScheduler` — application service orchestrating result recording and state persistence
- `SessionPlanner` — computes daily session plan (review_count + next_lesson); caches to Redis

**Does NOT own**:
- Exercise content (owned by `exercise` module)
- Lesson structure (owned by `curriculum` module)
- Persistence (delegated through `ReviewRepository` port)

**Driven port**: `ReviewRepository`
- `exercises_due_today(as_of_date:)` — returns exercises with next_review_date <= as_of_date
- `update_review_state(exercise_id:, interval:, ease_factor:, next_review_date:)` — atomic update
- `log_review_result(exercise_id:, result:, reviewed_at:)` — append to review_logs
- `deferred_exercises` — returns exercises flagged as deferred from prior session

**Invariants enforced**:
- ease_factor minimum 1.3 (BR-08)
- interval minimum 1 day (BR-07)
- Daily cap: max(12 exercises, 6 minutes) — (BR-04)
- Result types: `correct | incorrect | skipped | missed` only

---

## Domain Module: curriculum

**Bounded context**: Lesson tree structure, prerequisite enforcement, unlock lifecycle.

**Owns**:
- `PrerequisiteGraph` — in-memory DAG loaded from `db/curriculum/prerequisites.yml`; validates acyclicity at boot
- `CurriculumMap` — full 25-lesson curriculum with per-lesson status for a given progress state
- `LessonUnlocker` — evaluates and applies prerequisite unlock on lesson completion
- `LockScreenPolicy` — resolves lock screen content (why locked, prerequisite topics, completion status)

**Does NOT own**:
- SM-2 scheduling (owned by `sm2` module)
- Exercise content structure (owned by `exercise` module)

**Driven port**: `LessonRepository`
- `all_lessons` — returns all 25 lessons with content metadata
- `lesson_progress(lesson_id:)` — returns completion status for a lesson
- `complete_lesson(lesson_id:)` — marks lesson complete; called inside transaction with `unlock_lessons`
- `unlock_lessons(lesson_ids:)` — marks lessons available; called atomically with completion
- `available_lessons` — returns lessons with status = available
- `lesson_with_exercises(lesson_id:)` — returns lesson content + exercises

**Invariants enforced**:
- Lesson 1 is always available (BR-01)
- A lesson is available iff all prerequisite lessons are complete (BR-02)
- Unlock is atomic with completion — no partial state (BR-10)
- Prerequisite graph is acyclic (validated on load)

---

## Domain Module: session

**Bounded context**: Daily session lifecycle, plan computation, state persistence.

**Owns**:
- `SessionPlan` — value object: `{review_exercises: [...], next_lesson: Lesson, computed_at: Time}`
- `SessionState` — tracks current position in session (review index, lesson exercise index)
- `SessionClock` — enforces 15-minute session cap; coordinates with exercise timer

**Coordinates with**:
- `sm2::SessionPlanner` for review queue
- `curriculum::CurriculumMap` for next_lesson resolution

**Driven port**: `SessionRepository`
- `active_session` — returns current session plan (from Redis cache)
- `save_session_plan(plan:)` — persists plan to Redis on session open
- `save_exercise_position(lesson_id:, exercise_index:)` — saves Esc mid-lesson position
- `complete_session(session_id:)` — marks session complete; updates streak

**Invariants enforced**:
- Session plan computed once at open; cached for session duration (BR-12)
- Session does not cut off mid-exercise at 15-minute cap (BR-06)
- Review queue always runs before new lesson

---

## Domain Module: progress

**Bounded context**: Progress metrics derived from SM-2 and lesson completion data.

**Owns**:
- `ProgressDashboard` — computes: lessons_complete/25, per-module breakdown, per-lesson retention scores, streak, sessions_remaining estimate
- `RetentionCalculator` — computes retention score = correct_reviews / total_reviews (last 10) per lesson
- `StreakTracker` — consecutive calendar days with completed sessions

**Does NOT own**:
- SM-2 raw state (reads through `ReviewRepository` port)
- Lesson status (reads through `LessonRepository` port)

**No separate driven port** — reads via shared `ReviewRepository` and `LessonRepository` ports.

**Invariants enforced**:
- Retention score uses last 10 SM-2 reviews per lesson (or all if < 10)
- No gamification: no XP, no badge signals, no achievement language in data model
- Streak: calendar-day granularity, not session count

---

## Domain Module: exercise

**Bounded context**: Exercise type definitions, answer evaluation, hint policy.

**Owns**:
- Exercise types: `FillInTheBlank`, `MultipleChoice`, `SpotTheBug`, `Translate`, `TrueFalse`
- `AnswerEvaluator` — given exercise + submitted answer, returns `ResultType` (correct/incorrect/skipped/missed)
- `HintPolicy` — one hint per exercise; Tab reveals partial hint; second Tab no-ops

**Does NOT own**:
- Timer (handled by Stimulus controller in browser layer)
- SM-2 state update (owned by `sm2` module)

**Invariants enforced**:
- Timer result type `missed` maps to `incorrect` for SM-2 purposes (BR-05)
- `skipped` (Esc key) does not change ease_factor (BR-09)
- Hint does not reveal full answer

---

## Primary Adapters (Web Layer)

Rails controllers are primary adapters — they translate HTTP/Turbo requests into domain application service calls.

| Controller | Domain Services Called |
|-----------|----------------------|
| `SessionsController` | `SessionPlanner`, `SessionState` |
| `ExercisesController` | `AnswerEvaluator`, `ReviewScheduler` |
| `LessonsController` | `CurriculumMap`, `LessonUnlocker`, `LockScreenPolicy` |
| `ProgressController` | `ProgressDashboard` |
| `OnboardingController` | `CurriculumMap`, `SessionPlanner` |

Stimulus controllers (JavaScript):
- `KeyboardController` — global keyboard shortcut registration from config file
- `TimerController` — 30-second exercise countdown; triggers `missed` result on expiry
- `FocusController` — focus management on overlay open/close
- `SearchController` — client-side lesson tree filter

---

## Driven Adapters (Repository Layer)

| Port | Adapter | Data Store |
|------|---------|-----------|
| `ReviewRepository` | `ActiveRecord::ReviewRepository` | PostgreSQL |
| `LessonRepository` | `ActiveRecord::LessonRepository` | PostgreSQL |
| `SessionRepository` | `Redis::SessionRepository` | Redis (plan) + PostgreSQL (session log) |
| `ProgressRepository` | Shared via ReviewRepository + LessonRepository | PostgreSQL |

**Test adapters** (in-memory) provided for each port — used in domain unit tests. No DB required.

---

## Dependency Rules Matrix

| From \ To | sm2 domain | curriculum domain | session domain | progress domain | exercise domain | adapters/repositories | adapters/web |
|-----------|-----------|------------------|---------------|----------------|----------------|----------------------|-------------|
| sm2 domain | — | reads next_lesson | — | — | result types | via port | never |
| curriculum domain | — | — | — | — | — | via port | never |
| session domain | coordinates | coordinates | — | — | — | via port | never |
| progress domain | reads via port | reads via port | — | — | — | via port | never |
| exercise domain | — | — | — | — | — | never | never |
| adapters/repositories | implements port | implements port | implements port | — | — | — | never |
| adapters/web | calls app services | calls app services | calls app services | calls app services | calls app services | never | — |

**Key rule**: no upward dependency from domain to adapters. No cross-domain repository access.
