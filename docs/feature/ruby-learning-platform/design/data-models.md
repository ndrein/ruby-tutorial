# Data Models — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: DESIGN
**Date**: 2026-03-10
**Status**: Accepted

---

## Schema Overview

Seven tables. All timestamps in UTC. UUIDs used for user identity; integer PKs for content tables (stable, never user-visible per XC-001).

```
users
  └── has_many reviews
  └── has_many sessions
  └── has_many daily_queues

modules (seed data, static)
  └── has_many lessons

lessons (seed data, static)
  └── belongs_to module
  └── has_many exercises
  └── has_many lesson_prerequisites (join)

exercises (seed data, static)
  └── belongs_to lesson
  └── has_many reviews

reviews (SM-2 state — one row per user+exercise pair)
  └── belongs_to user
  └── belongs_to exercise

sessions (one per user per session event)
  └── belongs_to user

daily_queues (one per user per calendar day)
  └── belongs_to user
```

---

## Table Definitions

### `users`

```sql
CREATE TABLE users (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email                 VARCHAR(255) NOT NULL,
  experience_level      VARCHAR(20)  NOT NULL DEFAULT 'expert'
                          CHECK (experience_level IN ('expert', 'beginner')),
  password_digest       VARCHAR(255) NOT NULL,
  streak_count          INTEGER      NOT NULL DEFAULT 0 CHECK (streak_count >= 0),
  last_session_date     DATE,
  email_opted_in        BOOLEAN      NOT NULL DEFAULT FALSE,
  email_delivery_hour   INTEGER      NOT NULL DEFAULT 8
                          CHECK (email_delivery_hour BETWEEN 0 AND 23),
  timezone              VARCHAR(100) NOT NULL DEFAULT 'UTC',
  created_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT users_email_unique UNIQUE (email)
);
```

**Notes**:
- UUID primary key: user ID never appears in URLs or UI (XC-001)
- `experience_level = 'expert'` default: per critical constraint "Expert mode permanent"
- `password_digest`: bcrypt via `has_secure_password`; no plain-text passwords
- `last_session_date`: used by StreakUpdater to detect same-day second sessions (FR-9.7)
- `email_opted_in DEFAULT FALSE`: explicit opt-in required (FR-4.8, privacy constraint)

---

### `modules`

```sql
CREATE TABLE modules (
  id          INTEGER PRIMARY KEY,
  title       VARCHAR(255) NOT NULL,
  position    INTEGER      NOT NULL CHECK (position BETWEEN 1 AND 5),
  CONSTRAINT modules_position_unique UNIQUE (position)
);
```

Seed data only. 5 rows. Never updated by application logic.

---

### `lessons`

```sql
CREATE TABLE lessons (
  id                    INTEGER PRIMARY KEY,
  module_id             INTEGER      NOT NULL REFERENCES modules(id),
  title                 VARCHAR(255) NOT NULL,
  position_in_module    INTEGER      NOT NULL CHECK (position_in_module BETWEEN 1 AND 5),
  content_body          TEXT         NOT NULL,
  python_equivalent     TEXT         NOT NULL,
  java_equivalent       TEXT         NOT NULL,
  estimated_minutes     INTEGER      NOT NULL DEFAULT 5
                          CHECK (estimated_minutes BETWEEN 1 AND 5),
  prerequisite_ids      INTEGER[]    NOT NULL DEFAULT '{}',
  created_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT lessons_module_position_unique UNIQUE (module_id, position_in_module)
);

CREATE INDEX idx_lessons_module_id ON lessons(module_id);
```

**Notes**:
- `prerequisite_ids`: PostgreSQL integer array. Stores lesson IDs that must be completed before this lesson unlocks. DAG — no circular dependencies. Validated at seed time.
- `python_equivalent` and `java_equivalent`: required for all 25 lessons (NFR-6.2)
- `content_body`: may contain Markdown or structured HTML — crafter's choice for renderer
- Integer PK (1-25): stable identifiers; never user-visible

---

### `exercises`

```sql
CREATE TABLE exercises (
  id                  INTEGER PRIMARY KEY,
  lesson_id           INTEGER      NOT NULL REFERENCES lessons(id),
  exercise_type       VARCHAR(30)  NOT NULL
                        CHECK (exercise_type IN ('fill_in_blank', 'multiple_choice', 'spot_the_bug', 'translation')),
  prompt              TEXT         NOT NULL,
  correct_answer      VARCHAR(500) NOT NULL,
  accepted_synonyms   TEXT[]       NOT NULL DEFAULT '{}',
  explanation         TEXT         NOT NULL,
  options             TEXT[]       NOT NULL DEFAULT '{}',
  position            INTEGER      NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT exercises_lesson_position_unique UNIQUE (lesson_id, position)
);

CREATE INDEX idx_exercises_lesson_id ON exercises(lesson_id);
```

**Notes**:
- `options`: populated only for `multiple_choice` exercises; must have exactly 4 elements (enforced by seed validation)
- `accepted_synonyms`: for `fill_in_blank` — e.g., `['Array#select', 'select']` (FR-5.8)
- `explanation`: shown after every submission regardless of result (FR-5.6)
- At least 1 exercise per lesson enforced at seed time (NFR-6.1)

---

### `reviews`

The core SM-2 state table. One row per (user_id, exercise_id). Updated in-place after each review.

```sql
CREATE TABLE reviews (
  id                BIGINT       PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id           UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  exercise_id       INTEGER      NOT NULL REFERENCES exercises(id),
  sm2_interval      INTEGER      NOT NULL DEFAULT 1
                      CHECK (sm2_interval >= 1),
  sm2_ease_factor   DECIMAL(4,2) NOT NULL DEFAULT 2.50
                      CHECK (sm2_ease_factor >= 1.30 AND sm2_ease_factor <= 2.50),
  repetitions       INTEGER      NOT NULL DEFAULT 0 CHECK (repetitions >= 0),
  next_review_date  DATE         NOT NULL,
  answer_result     VARCHAR(20)  NOT NULL
                      CHECK (answer_result IN ('correct', 'incorrect', 'skipped', 'timeout')),
  quality_score     INTEGER      NOT NULL DEFAULT 0
                      CHECK (quality_score BETWEEN 0 AND 5),
  reviewed_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  created_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT reviews_user_exercise_unique UNIQUE (user_id, exercise_id)
);

CREATE INDEX idx_reviews_user_next_review ON reviews(user_id, next_review_date);
CREATE INDEX idx_reviews_user_exercise ON reviews(user_id, exercise_id);
```

**Notes**:
- `UNIQUE (user_id, exercise_id)`: enforces single-source — one SM-2 record per user-exercise pair
- `sm2_interval CHECK >= 1`: enforces NFR-7.1
- `sm2_ease_factor CHECK [1.30, 2.50]`: enforces NFR-7.2
- `idx_reviews_user_next_review`: primary query path for QueueBuilder (`WHERE user_id = ? AND next_review_date <= ?`)
- `DECIMAL(4,2)`: stores EF to 2 decimal places (sufficient for SM-2 precision)
- `reviewed_at`: actual timestamp of last review; `next_review_date = reviewed_at::date + sm2_interval`

---

### `sessions`

```sql
CREATE TABLE sessions (
  id                   BIGINT       PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id              UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  started_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  ended_at             TIMESTAMPTZ,
  duration_seconds     INTEGER      CHECK (duration_seconds IS NULL OR duration_seconds >= 0),
  exercises_completed  INTEGER      NOT NULL DEFAULT 0 CHECK (exercises_completed >= 0),
  session_date         DATE         NOT NULL,
  created_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sessions_user_date ON sessions(user_id, session_date);
```

**Notes**:
- `session_date`: the calendar date in user's timezone (derived from `started_at` + user timezone at session creation time). Used for streak calculation and same-day dedup.
- `ended_at`: NULL while session in progress; set on session completion.
- `duration_seconds`: set on completion: `EXTRACT(EPOCH FROM ended_at - started_at)::INTEGER`. Also used for cap enforcement (server derives elapsed from `started_at` on each request).
- `exercises_completed >= 1` required for streak credit (FR-9.6); enforced in SessionTracker, not DB constraint (zero is valid for incomplete sessions).
- NFR-7.4: `duration_seconds > 1800` indicates timer bug; monitored at application level.

---

### `daily_queues`

```sql
CREATE TABLE daily_queues (
  id              BIGINT       PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id         UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  queue_date      DATE         NOT NULL,
  exercise_ids    INTEGER[]    NOT NULL DEFAULT '{}',
  email_sent_at   TIMESTAMPTZ,
  created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT daily_queues_user_date_unique UNIQUE (user_id, queue_date)
);

CREATE INDEX idx_daily_queues_user_date ON daily_queues(user_id, queue_date);
CREATE INDEX idx_daily_queues_email_pending
  ON daily_queues(user_id, queue_date)
  WHERE email_sent_at IS NULL;
```

**Notes**:
- `UNIQUE (user_id, queue_date)`: idempotency key. `INSERT ... ON CONFLICT (user_id, queue_date) DO UPDATE SET exercise_ids = EXCLUDED.exercise_ids, updated_at = NOW()` (NFR-2.4).
- `exercise_ids`: ordered integer array. Order is preserved: oldest due first (FR-3.6). App reads this array directly; email reads this array directly. **Both read from the same row** — single source of truth for `review_queue` (critical constraint).
- `email_sent_at`: null until email dispatched. Prevents duplicate sends on retry. EmailDispatchJob checks `WHERE email_sent_at IS NULL` before sending.
- Partial index on `email_sent_at IS NULL` for efficient email dispatch queries.

---

## How `lesson_status` Is Derived (Never Stored)

`lesson_status` is computed at read time by `LessonStatusProjector` (FR-8.3). No column exists in any table.

**Derivation logic**:

```
For a given (user_id, lesson_id):

1. Check prerequisites:
   locked = lessons.prerequisite_ids.any? { |pid|
     no review record exists for (user_id, exercise in lesson pid)
   }
   → if locked: status = :locked

2. Check SM-2 state:
   max_interval = reviews
     .where(user_id: user_id)
     .joins(:exercise)
     .where(exercises: { lesson_id: lesson_id })
     .maximum(:sm2_interval)

   if max_interval.nil?
     status = :available       ← prerequisites met, never attempted
   elsif max_interval >= 30
     status = :mastered        ← SM-2 interval ≥ 30 days
   elsif max_interval >= 3
     status = :in_review       ← SM-2 interval 3-29 days
   else
     status = :new             ← SM-2 interval 1-2 days (first pass)
   end
```

**Why derived**: Storing `lesson_status` would create a second writer (any SM-2 update would require updating both reviews and lesson status). The shared-artifacts-registry explicitly flags this as a single-source violation to avoid.

---

## How `review_queue` Is Built from SM-2 State

```sql
-- QueueBuilder query (simplified)
SELECT
  r.exercise_id,
  e.lesson_id,
  r.next_review_date
FROM reviews r
JOIN exercises e ON e.id = r.exercise_id
WHERE r.user_id = :user_id
  AND r.next_review_date <= :today
ORDER BY r.next_review_date ASC;
-- (oldest due first — overdue exercises before today's exercises)
```

After query:
1. Estimate session budget: 45 seconds per exercise, total budget 900 seconds.
2. Calculate max exercises: `floor(900 / 45) = 20` exercises maximum.
3. Truncate ordered array at budget boundary (FR-3.5).
4. Upsert `daily_queues` row.

The `review_queue` is the `exercise_ids` column of the `daily_queues` row for today. App and email read from this column — never independently recompute.

---

## Migration Strategy for Walking Skeleton (US-000)

The walking skeleton requires the minimum schema to run end-to-end: one lesson, one exercise, one user, one review.

**M0 — Walking Skeleton migrations** (must exist before US-000 can run):

```
migrations/
  001_create_users.rb           — users table (email, experience_level, password_digest, streak_count)
  002_create_modules.rb         — modules table + seed 5 module rows
  003_create_lessons.rb         — lessons table + seed Lesson 1 (Ruby Blocks)
  004_create_exercises.rb       — exercises table + seed Exercise 1.1 (fill_in_blank, correct_answer: "select")
  005_create_reviews.rb         — reviews table with SM-2 columns
  006_create_sessions.rb        — sessions table (for session tracking)
  007_create_daily_queues.rb    — daily_queues table (for queue builder)
```

**Seed data for walking skeleton**:
- 1 user: `email=test@example.com`, `experience_level=expert`
- 1 module: `id=1, title="Ruby Fundamentals for Polyglots", position=1`
- 1 lesson: `id=1, title="Ruby Blocks", module_id=1, position_in_module=1, prerequisite_ids=[]`
- 1 exercise: `id=1, lesson_id=1, exercise_type=fill_in_blank, prompt="Complete: arr.____(){ |x| x > 3 }", correct_answer="select", accepted_synonyms=["Array#select"], explanation="select returns elements matching the block condition..."`

**Walking skeleton acceptance** (AC-000-04): After submitting "select" for Exercise 1, a `reviews` row exists with `next_review_date = today + 1` (first correct answer, quality 4, I(1)=1).

**Full schema migrations** (M1 onward): Remaining 24 lessons and their exercises added in batches by module. No schema changes required after M0 — all tables exist; content added as seed data.

---

## Index Summary

| Table | Index | Purpose |
|-------|-------|---------|
| users | email (UNIQUE) | Login lookup |
| lessons | module_id | Module → lessons fetch |
| exercises | lesson_id | Lesson → exercises fetch |
| reviews | (user_id, next_review_date) | Queue builder — primary query path |
| reviews | (user_id, exercise_id) UNIQUE | Enforce single SM-2 record |
| sessions | (user_id, session_date) | Streak calculation; same-day dedup |
| daily_queues | (user_id, queue_date) UNIQUE | Idempotency; queue lookup |
| daily_queues | partial: email_sent_at IS NULL | Email dispatch pending query |

---

## Data Constraints Summary (NFR-7)

| Constraint | Column | Enforcement |
|-----------|--------|-------------|
| sm2_interval ≥ 1 | reviews.sm2_interval | DB CHECK constraint |
| sm2_ease_factor in [1.30, 2.50] | reviews.sm2_ease_factor | DB CHECK constraint |
| streak_count ≥ 0 | users.streak_count | DB CHECK constraint |
| quality_score in [0, 5] | reviews.quality_score | DB CHECK constraint |
| experience_level enum | users.experience_level | DB CHECK constraint |
| answer_result enum | reviews.answer_result | DB CHECK constraint |
| exercise_type enum | exercises.exercise_type | DB CHECK constraint |
| duration_seconds ≥ 0 | sessions.duration_seconds | DB CHECK constraint |
| One SM-2 record per user+exercise | reviews(user_id, exercise_id) | DB UNIQUE constraint |
| One queue per user per day | daily_queues(user_id, queue_date) | DB UNIQUE constraint |
| One email per queue | daily_queues.email_sent_at | Application-level + partial index |
