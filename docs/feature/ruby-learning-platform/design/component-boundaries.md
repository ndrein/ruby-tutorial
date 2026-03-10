# Component Boundaries — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: DESIGN
**Date**: 2026-03-10
**Status**: Accepted

---

## Domain Model

The domain is organized around six primary entities. Each entity has exactly one authoritative writer, per the Single-Source Violations defined in the Shared Artifacts Registry.

### Lesson

**Responsibility**: Curriculum content; static after seeding.
**Owner**: Platform content (seed data). Never mutated by user actions.
**Key attributes**: id (1-25), title, module_id, position_in_module, content_body, python_equivalent, java_equivalent, estimated_minutes, prerequisite_lesson_ids (array)
**Relationships**: belongs_to Module; has_many Exercises; has_many (through) prerequisite lessons
**Invariants**:
- Exactly 25 lessons in 5 modules of 5
- No beginner content (NFR-6.3)
- All code examples syntactically valid Ruby (NFR-6.4)
- prerequisite_lesson_ids forms a DAG (no cycles)

### Exercise

**Responsibility**: Single review item associated with a lesson; static after seeding.
**Owner**: Platform content (seed data).
**Key attributes**: id, lesson_id, exercise_type (fill_in_blank | multiple_choice | spot_the_bug | translation), prompt, correct_answer, accepted_synonyms (array), explanation, options (array, for multiple_choice)
**Relationships**: belongs_to Lesson; has_many Reviews
**Invariants**:
- Each lesson has at least 1 exercise (NFR-6.1)
- correct_answer is non-empty
- For multiple_choice: exactly 4 options (FR-5.9)
- explanation present for all types (FR-5.6)

### Review

**Responsibility**: SM-2 state for one user + one exercise pair. The core persistence record for spaced repetition.
**Owner**: SM2Engine (writes after every exercise submission). **Single writer** (critical integration constraint).
**Key attributes**: id, user_id, exercise_id, sm2_interval (integer days, ≥1), sm2_ease_factor (float [1.3, 2.5]), repetitions (integer ≥0), next_review_date (date), answer_result (correct | incorrect | skipped | timeout), reviewed_at (timestamp), quality_score (0-5)
**Relationships**: belongs_to User; belongs_to Exercise
**Invariants**:
- One row per (user_id, exercise_id); updated in place after each review
- sm2_interval ≥ 1 (NFR-7.1)
- sm2_ease_factor in [1.3, 2.5] (NFR-7.2, NFR-5.2, NFR-5.3)
- next_review_date = reviewed_at.to_date + sm2_interval
- Never stores lesson_status — that is derived

### Session

**Responsibility**: Tracks one user's daily practice session for duration, cap enforcement, and streak.
**Owner**: SessionTracker. **Single writer**.
**Key attributes**: id, user_id, started_at (timestamp), ended_at (timestamp), duration_seconds (integer), exercises_completed (integer), session_date (date)
**Relationships**: belongs_to User
**Invariants**:
- duration_seconds ≤ 900 (session cap; NFR-7.4 flags > 1800 as bug)
- session_date = started_at.to_date (UTC)
- At most one streak increment per calendar day (FR-9.7)

### DailyQueue

**Responsibility**: Snapshot of today's exercise queue — shared authoritative source for both email and app (critical constraint: single queue builder).
**Owner**: QueueBuilder (nightly job). **Single writer**.
**Key attributes**: id, user_id, queue_date (date), exercise_ids (array of integers, ordered), created_at, email_sent_at (nullable timestamp)
**Relationships**: belongs_to User
**Invariants**:
- Unique on (user_id, queue_date) — enforced by DB unique index
- Immutable once session starts (FR-3.3)
- email_sent_at set exactly once per queue_date per user (idempotency guard)

### User

**Responsibility**: Account identity, preferences, streak state.
**Owner**: OnboardingController (creates), SettingsController (updates preferences).
**Key attributes**: id (UUID), email, experience_level (expert | beginner, default: expert), streak_count (integer ≥0), last_session_date (date nullable), email_opted_in (boolean), email_delivery_hour (integer 0-23, default: 8), timezone (string, default: UTC), password_digest, created_at
**Relationships**: has_many Reviews; has_many Sessions; has_many DailyQueues
**Invariants**:
- email is unique (AC-001-04)
- streak_count ≥ 0 (NFR-7.3)
- experience_level = expert once set via onboarding (permanent — critical constraint)

---

## Service Boundaries

### SM2Engine (Pure Function — Critical)

**Type**: Stateless service object (pure function).
**Input**: `SM2Input` value object — `{ repetitions: Integer, interval: Integer, ease_factor: Float, quality: Integer(0-5) }`
**Output**: `SM2Result` value object — `{ interval: Integer, ease_factor: Float, repetitions: Integer, next_review_date: Date }`
**Dependencies**: None. No ActiveRecord. No Time.current. Caller passes `today: Date` if date injection needed for testing.
**Behavior**:
- quality < 3: interval = 1, repetitions = 0
- quality >= 3, repetitions = 0: interval = 1
- quality >= 3, repetitions = 1: interval = 6
- quality >= 3, repetitions > 1: interval = round(previous_interval * ease_factor)
- EF formula: `EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))`
- EF clamp: max(1.3, min(2.5, EF'))
- new repetitions = quality >= 3 ? repetitions + 1 : 0
**Test coverage required**: First scheduling, second scheduling, third+ scheduling, reset on q<3, EF bounds (min and max), all valid quality scores 0-5 (NFR-5.5).

**Why pure**: SM-2 correctness is the product's core promise. Purity ensures unit tests are fast, deterministic, and unambiguous. Any test failure is a logic bug, not an environment issue.

### ScoreCalculator (Pure Function)

**Type**: Stateless service object (pure function).
**Input**: `answer_result (Symbol)`, `elapsed_seconds (Integer)`, `hard_flag (Boolean)`
**Output**: `Integer (0-5)`
**Logic** (per FR-2.3):
- `timeout` or `skipped`: score = 0
- `incorrect`: score = 1
- `correct` + hard_flag: score = 3
- `correct` + elapsed < 10: score = 5
- `correct` + elapsed 10–24: score = 4
- `correct` + elapsed 25–30: score = 3
- Score 2: correct after first skip — handled by caller passing `second_attempt: true`
**Dependencies**: None.

### QueueBuilder (Service Object with DB Access)

**Type**: Service object. Not a pure function — reads DB.
**Input**: `user_id (Integer)`, `date (Date)`
**Output**: `Array<Hash>` — `[{ exercise_id:, lesson_id:, next_review_date: }, ...]`
**Behavior**:
1. Query reviews where `user_id = ? AND next_review_date <= ?`; order by `next_review_date ASC` (overdue first — FR-3.6)
2. Apply budget cap: estimate 45 seconds per exercise; drop items beyond 15-minute budget (FR-3.5)
3. Return ordered array
**Idempotency**: Same inputs always produce same output. Deterministic ordering.
**Used by**: Both `QueueBuilderJob` (nightly, persists to `daily_queues`) and `SessionsController` (reads from `daily_queues` at session start — does not re-query reviews).
**Critical constraint**: Email and app must read from the same `daily_queues` row. App does NOT call QueueBuilder directly at session start — it reads the pre-built `DailyQueue` record. This guarantees email/app consistency (FR-3.2, AC-004-02).

### SessionTracker (Service Object with DB Access)

**Type**: Service object. Reads and writes `sessions` table.
**Responsibilities**:
- `start(user_id, date)`: Create session record, record started_at
- `record_exercise(session_id)`: Increment exercises_completed
- `check_budget(session_id)`: Compute elapsed, return `{ elapsed_seconds:, remaining_seconds:, cap_reached: }`
- `complete(session_id)`: Set ended_at, duration_seconds; call StreakUpdater
**Session cap enforcement**: `check_budget` is called before every new exercise is dispatched to the user. If `remaining_seconds < 30` (one exercise minimum), cap is signaled and no new exercise starts. This is called server-side, not client-side.

### PrerequisiteChecker (Service Object with DB Access)

**Type**: Service object. Reads lessons and reviews tables.
**Input**: `lesson_id`, `user_id`
**Output**: `{ gated: Boolean, prerequisites: [{ lesson_id:, title:, completed: Boolean }], sessions_to_unlock: Integer }`
**Behavior**: Checks `prerequisite_lesson_ids` array from Lesson; for each, checks if user has a Review record with `answer_result = correct` (or any completed submission indicating lesson was accessed). Estimates sessions to unlock as unfulfilled prerequisite count.

### LessonStatusProjector (Query Object — Derives lesson_status)

**Type**: Query object. No writes.
**Input**: `user_id`, optionally `lesson_ids` (array) or single `lesson_id`
**Output**: Hash of `{ lesson_id => :mastered | :in_review | :new | :available | :locked }`
**Derivation logic** (per FR-8.3, shared-artifacts-registry `lesson_status`):
- `locked`: prerequisite lessons not all completed (PrerequisiteChecker returns gated: true)
- `mastered`: max sm2_interval for this lesson's exercises ≥ 30 days
- `in_review`: max sm2_interval 3–29 days
- `new`: first pass complete (review record exists, repetitions ≥ 1), max interval 1–2 days
- `available`: prerequisite met, no review record exists yet
**Never stored**: lesson_status is computed on read. No field in the database.

---

## Controller Responsibilities

Controllers are thin — they translate HTTP to service object calls and render responses.

### OnboardingController
- `GET /register` — render registration form
- `POST /register` — validate email, create User, redirect to experience step
- `GET /onboarding/experience` — render experience question
- `POST /onboarding/experience` — set experience_level, redirect to Lesson 1
- `GET /onboarding/email_preferences` — render email opt-in
- `POST /onboarding/email_preferences` — save email_opted_in + delivery_hour

### LessonsController
- `GET /lessons/:id` — load lesson content, render with language comparison
- Does not call SM2Engine (lessons are content, not review events)

### ExercisesController
- `GET /exercises/:id` — render exercise (auto-focus input per AC-005-01)
- `POST /exercises/:id/submit` — receive answer + elapsed_seconds + hard_flag; call ScoreCalculator; call SM2Engine; persist Review; call SessionTracker.record_exercise; render Turbo Frame feedback
- Does not directly touch SM2 math — delegates entirely to service objects

### SessionsController
- `GET /session/start` — call QueueBuilder (reads DailyQueue); call SessionTracker.start; render session start screen
- `POST /session/complete` — call SessionTracker.complete; render session summary

### DashboardController
- `GET /dashboard` — call LessonStatusProjector for all 25 lessons; compute mastered_count, in_review_count, new_count from projector; compute retention_rate from reviews table query; render dashboard

### CurriculumController
- `GET /curriculum` — call LessonStatusProjector; call PrerequisiteChecker for locked lessons; render curriculum view with status indicators (FR-8.2)

---

## Model vs. Service Layer Responsibilities

| Concern | Location | Rationale |
|---------|----------|-----------|
| SM-2 calculation | SM2Engine service | Pure function; zero Rails dependencies; isolated testability |
| Score derivation | ScoreCalculator service | Pure function; algorithm specification per FR-2.3 |
| Queue building | QueueBuilder service | Complex query + business rules; not an AR concern |
| Session cap enforcement | SessionTracker service | Requires cross-request state (started_at); not a per-model concern |
| lesson_status derivation | LessonStatusProjector | Multi-table query with business rules; model scopes would leak logic |
| prerequisite checking | PrerequisiteChecker | Multi-model query with graph logic |
| Data persistence | ActiveRecord models | Standard CRUD; validations; associations |
| Attribute validations | ActiveRecord models | Range checks (ease_factor bounds), presence, uniqueness |
| Email formatting | Action Mailer (DailyQueueMailer) | Presentation layer for email |

**Rule**: ActiveRecord models hold data validations and associations. Service objects hold logic that spans multiple models, requires pure function behavior, or implements business algorithms. Controllers call service objects, not business logic directly.

---

## SM-2 Algorithm Interface Specification

```
SM2Engine.call(input) -> result

Input (SM2Input):
  repetitions:   Integer   — number of prior correct reviews (0 = first attempt)
  interval:      Integer   — previous interval in days (1 if repetitions < 2)
  ease_factor:   Float     — current EF value (2.5 initial; clamped [1.3, 2.5])
  quality:       Integer   — response quality 0-5 (from ScoreCalculator)

Output (SM2Result):
  interval:         Integer   — new interval in days (always >= 1)
  ease_factor:      Float     — new EF (clamped to [1.3, 2.5])
  repetitions:      Integer   — new repetition count
  next_review_date: Date      — today + interval (caller passes today: Date for testability)

Constraints:
  - No side effects. No I/O. No Time.current calls inside the engine.
  - Deterministic: same input always produces same output.
  - Does not access the database.
  - Does not reference User, Review, or any ActiveRecord model.
  - Date injection: caller supplies date; default Date.today when called from production.

Algorithm:
  if quality < 3:
    new_interval   = 1
    new_repetitions = 0
  elsif repetitions == 0:
    new_interval   = 1
    new_repetitions = 1
  elsif repetitions == 1:
    new_interval   = 6
    new_repetitions = 2
  else:
    new_interval   = (interval * ease_factor).round
    new_repetitions = repetitions + 1

  new_ef = ease_factor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
  new_ef = [[new_ef, 1.3].max, 2.5].min

  next_review_date = today + new_interval
```

This specification is the contract between the architecture and the software-crafter. Internal implementation (class structure, method decomposition) is crafter's choice. The contract is: given these inputs, produce these outputs with these invariants.
