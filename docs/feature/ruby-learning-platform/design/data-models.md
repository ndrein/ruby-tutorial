# Data Models — Ruby Learning Platform

**Date**: 2026-03-09
**Database**: PostgreSQL 17

All models follow ActiveRecord conventions. Domain objects are separate from ActiveRecord models — repositories translate between them.

---

## Entity Relationship Overview

```
Module (1) ────────< Lesson (N)
Lesson (1) ────────< Exercise (N)
Lesson (N) >──────< Lesson (N)  [via PrerequisiteEdge]
Exercise (1) ───────< ReviewLog (N)
Exercise (1) ──────── ReviewState (1)
Session (1) ────────< SessionExercise (N)
```

---

## Table: modules

Groups of 5 thematically related lessons.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | bigint | PK | |
| slug | varchar(50) | NOT NULL, UNIQUE | e.g., `module_1_basics` |
| title | varchar(255) | NOT NULL | e.g., `Module 1: Ruby Foundations` |
| position | integer | NOT NULL | Display order (1–5) |
| created_at | timestamp | NOT NULL | |
| updated_at | timestamp | NOT NULL | |

**Index**: `position` (ordered display)

---

## Table: lessons

Individual learning units; 25 total across 5 modules.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | bigint | PK | |
| module_id | bigint | FK → modules.id, NOT NULL | |
| slug | varchar(100) | NOT NULL, UNIQUE | e.g., `l01_method_syntax` |
| title | varchar(255) | NOT NULL | |
| position | integer | NOT NULL | Within module (1–5) |
| duration_estimate_minutes | integer | NOT NULL | Expected session time |
| topics_covered | text[] | NOT NULL | Array of topic strings |
| topics_not_covered | text[] | NOT NULL | Explicit "does not cover" list (US-06) |
| content_source | varchar(255) | NOT NULL | Path to YAML content file |
| created_at | timestamp | NOT NULL | |
| updated_at | timestamp | NOT NULL | |

**Indexes**: `module_id`, `position`, `slug`

---

## Table: prerequisite_edges

Directed edges of the prerequisite DAG. `from_lesson_id` must be complete before `to_lesson_id` unlocks.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | bigint | PK | |
| from_lesson_id | bigint | FK → lessons.id, NOT NULL | Prerequisite (must be complete) |
| to_lesson_id | bigint | FK → lessons.id, NOT NULL | Target (unlocks when from is complete) |
| created_at | timestamp | NOT NULL | |

**Constraint**: `UNIQUE(from_lesson_id, to_lesson_id)`
**Constraint**: No self-referential edges (`from_lesson_id != to_lesson_id`)
**Index**: `to_lesson_id` (queried on lesson completion to find newly available)

*Note*: Populated from `db/curriculum/prerequisites.yml` via seed. Graph acyclicity validated in `PrerequisiteGraph#load` at boot.

---

## Table: exercises

Individual practice items within lessons. 75 total (3 per lesson).

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | bigint | PK | |
| lesson_id | bigint | FK → lessons.id, NOT NULL | |
| exercise_type | varchar(50) | NOT NULL | `fill_in_the_blank | multiple_choice | spot_the_bug | translate | true_false` |
| position | integer | NOT NULL | Display order within lesson (1–3) |
| prompt | text | NOT NULL | Exercise question/prompt |
| python_java_example | text | | Comparison code (US-06 requirement) |
| correct_answer | text | NOT NULL | Canonical correct answer |
| hint | text | | Partial hint shown on Tab; does not reveal full answer |
| explanation | text | NOT NULL | Ruby-specific explanation shown after answer |
| choices | jsonb | | For multiple_choice: `["a", "b", "c", "d"]` |
| created_at | timestamp | NOT NULL | |
| updated_at | timestamp | NOT NULL | |

**Index**: `lesson_id, position`

---

## Table: review_states

SM-2 scheduling state per exercise. One row per exercise. Created on first exercise completion.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | bigint | PK | |
| exercise_id | bigint | FK → exercises.id, NOT NULL, UNIQUE | |
| ease_factor | decimal(4,2) | NOT NULL, DEFAULT 2.5 | Min 1.3 (BR-08) |
| current_interval | integer | NOT NULL, DEFAULT 1 | Days |
| next_review_date | date | NOT NULL | Date exercise is next due |
| deferred | boolean | NOT NULL, DEFAULT false | True if deferred from prior session (BR-04) |
| last_result | varchar(20) | | `correct | incorrect | skipped | missed` |
| total_reviews | integer | NOT NULL, DEFAULT 0 | Cumulative review count |
| created_at | timestamp | NOT NULL | |
| updated_at | timestamp | NOT NULL | |

**Index**: `next_review_date` (primary SM-2 queue query)
**Index**: `exercise_id` (UNIQUE)
**Index**: `deferred` (partial: WHERE deferred = true; for deferred carry-over)

---

## Table: review_logs

Append-only log of every exercise result. Source of truth for retention score calculations.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | bigint | PK | |
| exercise_id | bigint | FK → exercises.id, NOT NULL | |
| session_id | bigint | FK → sessions.id | Nullable: exercises outside formal session |
| result | varchar(20) | NOT NULL | `correct | incorrect | skipped | missed` |
| reviewed_at | timestamp | NOT NULL | |
| prior_interval | integer | | Interval before this review |
| new_interval | integer | | Interval after this review |
| prior_ease_factor | decimal(4,2) | | |
| new_ease_factor | decimal(4,2) | | |

**Index**: `exercise_id, reviewed_at DESC` (retention score: last 10 reviews per exercise)
**Index**: `session_id`
**Index**: `reviewed_at` (streak and progress queries)

*Retention score computation*: for each lesson, aggregate last 10 `review_logs` rows across all lesson exercises where result = `correct`.

---

## Table: lesson_progress

Per-lesson completion and unlock state.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | bigint | PK | |
| lesson_id | bigint | FK → lessons.id, NOT NULL, UNIQUE | |
| status | varchar(20) | NOT NULL, DEFAULT 'locked' | `locked | available | complete` |
| completed_at | timestamp | | Set when last exercise committed |
| current_exercise_position | integer | NOT NULL, DEFAULT 0 | Esc mid-lesson save point (US-01 AC-01-15) |
| created_at | timestamp | NOT NULL | |
| updated_at | timestamp | NOT NULL | |

**Index**: `lesson_id` (UNIQUE)
**Index**: `status` (CurriculumMap query: all available lessons)

---

## Table: sessions

Daily practice session records.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | bigint | PK | |
| date | date | NOT NULL, UNIQUE | Calendar day of session |
| status | varchar(20) | NOT NULL, DEFAULT 'in_progress' | `in_progress | complete` |
| review_count_planned | integer | NOT NULL, DEFAULT 0 | From session plan |
| review_count_completed | integer | NOT NULL, DEFAULT 0 | Actual completed |
| lesson_id | bigint | FK → lessons.id | New lesson in session |
| started_at | timestamp | NOT NULL | |
| completed_at | timestamp | | Set on session complete |
| duration_seconds | integer | | Actual session duration |

**Index**: `date` (UNIQUE; streak calculation)
**Index**: `status` (active session lookup)

*Streak*: consecutive rows with `status = complete` by `date DESC`.

---

## Table: user_config

Single-row configuration table. No auth; no user_id.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | bigint | PK | Always 1 |
| onboarding_complete | boolean | NOT NULL, DEFAULT false | First-launch detection (US-01) |
| notification_enabled | boolean | NOT NULL, DEFAULT false | Post-MVP email opt-in |
| notification_email | varchar(255) | | Post-MVP |
| notification_time | time | | Post-MVP: preferred send time |
| created_at | timestamp | NOT NULL | |
| updated_at | timestamp | NOT NULL | |

---

## Data Flow: SM-2 Exercise Result

```
User submits answer
  → ExercisesController (primary adapter)
  → AnswerEvaluator (exercise domain) → ResultType
  → ReviewScheduler (sm2 domain)
      → SM2Algorithm.compute(interval, ease_factor, result) → {new_interval, new_ease_factor, next_review_date}
      → ReviewRepository.update_review_state(...)   [review_states UPDATE]
      → ReviewRepository.log_review_result(...)      [review_logs INSERT]
  ← Turbo Frame response with feedback HTML
```

## Data Flow: Lesson Completion + Prerequisite Unlock

```
Last exercise in lesson submitted
  → ExercisesController
  → LessonUnlocker (curriculum domain)
      → DB Transaction:
          LessonRepository.complete_lesson(lesson_id)        [lesson_progress UPDATE status=complete]
          LessonRepository.unlock_lessons(newly_available)   [lesson_progress UPDATE status=available]
      → Transaction commits
  → SessionController updates session record
  ← Render lesson-complete screen with unlocked lessons
```

## Data Flow: Session Plan Computation (BR-12)

```
SessionsController#create (session open)
  → SessionPlanner (sm2 domain)
      → ReviewQueue.compute(as_of_date: today)
          → ReviewRepository.exercises_due_today(...)    [review_states SELECT]
          → ReviewRepository.deferred_exercises          [review_states SELECT WHERE deferred=true]
          → Apply cap: min(12, 6 min estimate)
      → CurriculumMap.next_available_lesson
          → LessonRepository.available_lessons           [lesson_progress SELECT]
      → SessionPlan value object
  → SessionRepository.save_session_plan(plan)            [Redis SET session_plan:{id}]
  ← Render session dashboard
```

---

## PostgreSQL-Specific Decisions

- `text[]` for `topics_covered` / `topics_not_covered`: simple array of strings; no separate join table needed for 25 lessons.
- `jsonb` for `exercises.choices`: flexible for multiple-choice variations without extra table.
- `decimal(4,2)` for `ease_factor`: range 1.30–9.99; sufficient precision for SM-2.
- No `users` table: single-user system; `user_config` holds the single-row global config.
- Append-only `review_logs`: never update or delete; enables retention score recalculation from source data.
