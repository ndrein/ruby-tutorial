# Shared Artifacts Registry — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: DISCUSS — Phase 2 (Coherence Validation)
**Date**: 2026-03-09
**Purpose**: Single source of truth for every `${variable}` used across all three journey maps.
Every variable that appears in a journey (visual, YAML, or Gherkin) must have exactly one
authoritative source recorded here. Integration failures occur when two components write
to the same artifact or when a reader consumes a stale version.

---

## Artifact Registry

Each entry records: variable name, data type, authoritative source (the one writer),
consumers (all readers), first produced (journey step), and integration risk.

---

### `${user_id}`

| Field | Value |
|-------|-------|
| Type | String (UUID) |
| Description | Unique platform identifier for Marcus's account |
| Written by | Authentication / account creation (Onboarding Step 3) |
| Read by | All authenticated views; SM-2 engine; email delivery; streak tracker |
| First produced | Journey: Onboarding, Step 3 |
| Integration risk | LOW — standard auth identifier; must persist across sessions |
| Notes | Never exposed in UI; internal reference only |

---

### `${user_email}`

| Field | Value |
|-------|-------|
| Type | String (email address) |
| Description | Marcus's email address for daily queue delivery |
| Written by | Account creation form (Onboarding Step 3) |
| Read by | Daily email delivery service; email opt-in confirmation (Step 10) |
| First produced | Journey: Onboarding, Step 3 |
| Integration risk | MEDIUM — must link correctly to `${review_queue}` for email delivery |
| Notes | Must not be used for marketing without separate consent |

---

### `${experience_level}`

| Field | Value |
|-------|-------|
| Type | Enum: `expert` \| `beginner` |
| Description | User's self-declared experience level; drives curriculum filtering |
| Written by | Experience confirmation question (Onboarding Step 4) |
| Read by | Curriculum view (lesson availability filtering); lesson content rendering |
| First produced | Journey: Onboarding, Step 4 |
| Integration risk | HIGH — if not persisted correctly, Marcus sees beginner content (broken core promise) |
| Notes | Drives which lessons appear in Module 1 onward; default is `expert` for this product |

---

### `${curriculum_list}`

| Field | Value |
|-------|-------|
| Type | Array of lesson objects `[{id, title, module_id, prerequisites, status}]` |
| Description | The full 25-lesson curriculum with metadata |
| Written by | Platform content (static, seeded at build time); `${lesson_status}` updates dynamically |
| Read by | Onboarding Step 2 (curriculum preview); Topic Selection Step 4 (curriculum map) |
| First produced | Platform bootstrap (seed data) |
| Integration risk | MEDIUM — static content but `${lesson_status}` overlay must be applied per-user |
| Notes | Module grouping (5 modules x 5 lessons) must be preserved in all views |

---

### `${lesson_id}`

| Field | Value |
|-------|-------|
| Type | Integer (1-25) |
| Description | Identifier for a specific lesson in the 25-lesson curriculum |
| Written by | Platform content (seed data) |
| Read by | Lesson view renderer; exercise loading; SM-2 engine (to schedule exercises); session queue |
| First produced | Platform bootstrap |
| Integration risk | LOW — static identifier; referenced by exercises and SM-2 entries |
| Notes | Lesson IDs are stable and never change post-launch |

---

### `${lesson_content}`

| Field | Value |
|-------|-------|
| Type | Structured content object (title, body text, code examples, cross-language comparison) |
| Description | The full rendered content of a lesson including Python/Java side-by-side |
| Written by | Platform content (seed data) |
| Read by | Lesson view (Onboarding Step 5; Daily Session Step 9; Topic Selection Step 6) |
| First produced | Platform bootstrap |
| Integration risk | LOW — static content per lesson |
| Notes | Must include `python_equivalent` and `java_equivalent` fields for all 25 lessons |

---

### `${lesson_status}`

| Field | Value |
|-------|-------|
| Type | Enum: `mastered` \| `in_review` \| `new` \| `available` \| `locked` |
| Description | Marcus's current status for each lesson, derived from SM-2 state and prerequisite completion |
| Written by | SM-2 engine (updates on each review); prerequisite checker (updates on lesson completion) |
| Read by | Curriculum view; dashboard mastery counts; lesson detail card; session start screen |
| First produced | First exercise completion (SM-2 creates first entry) |
| Integration risk | HIGH — must derive from SM-2 interval data, not an independent status field; desync = wrong curriculum view |
| Notes | `mastered` = SM-2 interval >= 30 days; `in_review` = interval 3-29 days; `new` = first pass complete |

---

### `${module_id}`

| Field | Value |
|-------|-------|
| Type | Integer (1-5) |
| Description | Identifier for one of the 5 curriculum modules |
| Written by | Platform content (seed data) |
| Read by | Curriculum overview; module progress view; prerequisite gate logic |
| First produced | Platform bootstrap |
| Integration risk | LOW — static grouping |
| Notes | Module boundaries: M1=L1-5, M2=L6-10, M3=L11-15, M4=L16-20, M5=L21-25 |

---

### `${module_progress}`

| Field | Value |
|-------|-------|
| Type | Object `{completed: Integer, total: Integer, percentage: Float}` |
| Description | Count of lessons completed within a module, with percentage |
| Written by | Derived calculation: count of lessons in module where `lesson_status` != `locked` and != `available` |
| Read by | Module progress view (Topic Selection Step 8); curriculum overview module headers |
| First produced | After first lesson completion in each module |
| Integration risk | MEDIUM — must recalculate immediately after `${lesson_status}` changes |
| Notes | "Completed" = any status other than locked or available; stale cache = wrong progress % |

---

### `${prerequisite_ids}`

| Field | Value |
|-------|-------|
| Type | Array of lesson IDs `[Integer]` |
| Description | List of lesson IDs that must be completed before a given lesson unlocks |
| Written by | Platform content (seed data — static prerequisite graph) |
| Read by | Prerequisite gate view (Topic Selection Step 5); lesson availability check |
| First produced | Platform bootstrap |
| Integration risk | MEDIUM — prerequisite gate must check `${lesson_status}` for each ID in real time |
| Notes | Prerequisite graph is a DAG; no circular dependencies permitted |

---

### `${exercise_id}`

| Field | Value |
|-------|-------|
| Type | Integer |
| Description | Identifier for a specific review exercise linked to a lesson |
| Written by | Platform content (seed data); each lesson has 1+ exercises |
| Read by | Exercise renderer; SM-2 engine (to update interval per exercise); session queue |
| First produced | Platform bootstrap |
| Integration risk | LOW — static; 1:N relationship with `${lesson_id}` |
| Notes | Each lesson has at least 1 exercise; SM-2 tracks state per exercise_id, not per lesson_id |

---

### `${timer_seconds}`

| Field | Value |
|-------|-------|
| Type | Integer (0-30) |
| Description | Elapsed seconds when Marcus submits an exercise answer |
| Written by | Exercise timer (client-side countdown; records elapsed at submission) |
| Read by | SM-2 engine (response time influences ease factor calculation) |
| First produced | Exercise submission (Onboarding Step 6; Daily Session Steps 3-6, 10) |
| Integration risk | MEDIUM — fast response = stronger ease factor signal; must be submitted with answer |
| Notes | Timer shows countdown (30→0); `timer_seconds` = 30 - remaining at submission time |

---

### `${answer_result}`

| Field | Value |
|-------|-------|
| Type | Enum: `correct` \| `incorrect` \| `skipped` \| `timeout` |
| Description | Marcus's answer evaluation result for a single exercise |
| Written by | Answer evaluation engine (compares input to correct_answer) |
| Read by | Feedback panel renderer; SM-2 engine (result determines interval direction) |
| First produced | Exercise submission (Onboarding Step 6) |
| Integration risk | HIGH — incorrect evaluation = wrong SM-2 interval; `correct` must be exact match or accepted synonym |
| Notes | For fill-in-the-blank: exact match + accepted synonyms list; for multiple choice: exact match |

---

### `${explanation}`

| Field | Value |
|-------|-------|
| Type | String (plain text with code examples) |
| Description | Post-answer explanation shown regardless of correct/incorrect result |
| Written by | Platform content (seed data — one explanation per exercise) |
| Read by | Feedback panel (Onboarding Step 7) |
| First produced | Platform bootstrap |
| Integration risk | LOW — static content per exercise |
| Notes | Must connect answer to Python/Java equivalent where applicable |

---

### `${sm2_score}`

| Field | Value |
|-------|-------|
| Type | Integer (0-5) — SM-2 quality of response scale |
| Description | SM-2 response quality score derived from answer_result + timer_seconds |
| Written by | SM-2 scoring function: `correct + fast` = 5; `correct + slow` = 4; `correct + hard` = 3; `incorrect` = 1; `timeout/skip` = 0 |
| Read by | SM-2 interval calculation engine |
| First produced | Answer evaluation (Daily Session Steps 3-6) |
| Integration risk | HIGH — incorrect scoring = incorrectly calibrated intervals; core algorithm input |
| Notes | SM-2 algorithm specification: score 0-2 resets interval to 1 day; score 3+ extends interval |

---

### `${sm2_interval}`

| Field | Value |
|-------|-------|
| Type | Integer (days until next review) |
| Description | Number of days until this exercise should be reviewed again |
| Written by | SM-2 interval calculation engine (uses score + repetition_count + ease_factor) |
| Read by | Review queue builder; SM-2 scheduling confirmation panel; session summary |
| First produced | First exercise completion (Onboarding Step 8) |
| Integration risk | HIGH — this drives the entire review schedule; calculation bugs = broken core feature |
| Notes | SM-2 algorithm: I(1)=1, I(2)=6, I(n)=I(n-1)*EF; EF starts at 2.5, adjusted by score |

---

### `${sm2_ease_factor}`

| Field | Value |
|-------|-------|
| Type | Float (1.3 - 2.5, SM-2 standard range) |
| Description | Ease factor per exercise; adjusts interval growth rate based on response difficulty |
| Written by | SM-2 ease factor update function: EF = EF + (0.1 - (5-score) * (0.08 + (5-score) * 0.02)) |
| Read by | SM-2 interval calculation (multiplied by previous interval) |
| First produced | First exercise review (after initial interval expires) |
| Integration risk | HIGH — ease factor drift below 1.3 = pathologically short intervals |
| Notes | Minimum clamped at 1.3 per SM-2 spec; never displayed to user (implementation detail) |

---

### `${next_review_date}`

| Field | Value |
|-------|-------|
| Type | Date (ISO 8601) |
| Description | Calendar date when this exercise is next scheduled for review |
| Written by | SM-2 scheduling engine: `today + sm2_interval` |
| Read by | Review queue builder; SM-2 scheduling confirmation panel (Onboarding Step 8); session summary; daily email |
| First produced | Onboarding Step 8 (first SM-2 scheduling) |
| Integration risk | HIGH — drives email queue content; incorrect date = Marcus doesn't see exercise when he should |
| Notes | Exercises due on weekends are not pushed to weekdays (user practices daily) |

---

### `${review_queue}`

| Field | Value |
|-------|-------|
| Type | Array of exercise objects scheduled for today `[{exercise_id, lesson_id, next_review_date}]` |
| Description | Today's set of exercises scheduled by SM-2 for review |
| Written by | Daily queue builder: runs nightly, selects exercises where `next_review_date <= today` |
| Read by | Daily email content; session start screen; exercise delivery engine |
| First produced | Day 3 after onboarding (first SM-2 review scheduled 3 days after first exercise) |
| Integration risk | HIGH — email must show identical queue as app; queue must be idempotent (same result if built twice) |
| Notes | Queue is rebuilt each night; partial completion is persisted within a session |

---

### `${queue_count}`

| Field | Value |
|-------|-------|
| Type | Integer |
| Description | Number of exercises in today's review queue |
| Written by | Daily queue builder (count of review_queue array) |
| Read by | Daily email subject line; session start screen; time estimate calculator |
| First produced | Same as `${review_queue}` |
| Integration risk | LOW — derived count; must match len(review_queue) |

---

### `${session_duration}`

| Field | Value |
|-------|-------|
| Type | Integer (seconds) |
| Description | Total elapsed time for Marcus's current session |
| Written by | Session timer (starts on session start screen Enter; stops on summary screen) |
| Read by | Session summary panel; 15-minute cap enforcement; `${time_remaining}` calculation |
| First produced | Session start (Onboarding Step 2) |
| Integration risk | MEDIUM — must be accurate; must stop on session end, not on idle |
| Notes | Measured in seconds; displayed as "Xm Ys" in UI |

---

### `${time_remaining}`

| Field | Value |
|-------|-------|
| Type | Integer (seconds) |
| Description | Remaining time in Marcus's 15-minute daily session budget |
| Written by | Derived: `900 - session_duration` (900 = 15 minutes in seconds) |
| Read by | Session start screen; queue summary (lesson offer decision); session hard cap enforcement |
| First produced | Session start |
| Integration risk | MEDIUM — must update in near-real-time to inform lesson offer decision |
| Notes | 900 seconds = 15 minutes hard cap; hard cap enforcement is structural (platform stops, not user decides) |

---

### `${streak_count}`

| Field | Value |
|-------|-------|
| Type | Integer |
| Description | Number of consecutive calendar days Marcus has completed at least one session |
| Written by | Streak tracker: increments once per calendar day on first completed session |
| Read by | Session summary; daily email; dashboard |
| First produced | Onboarding (Step 9) — Day 1 = streak of 1 |
| Integration risk | MEDIUM — must increment once per day; must not increment on second session same day |
| Notes | "Completed session" = at least 1 exercise answered (not just opening the app) |

---

### `${mastered_count}`

| Field | Value |
|-------|-------|
| Type | Integer |
| Description | Number of concepts where SM-2 interval >= 30 days |
| Written by | Dashboard calculation: count of exercises where `sm2_interval >= 30` |
| Read by | Dashboard mastery overview; dashboard progress bar |
| First produced | After first concept reaches 30-day interval (approximately week 5-6) |
| Integration risk | LOW — derived count; recalculates on dashboard load |
| Notes | Presented alongside `${in_review_count}` and `${new_count}` |

---

### `${in_review_count}`

| Field | Value |
|-------|-------|
| Type | Integer |
| Description | Number of concepts where SM-2 interval is 3-29 days |
| Written by | Dashboard calculation |
| Read by | Dashboard mastery overview |
| First produced | Day 4 after onboarding (first exercise enters review cycle) |
| Integration risk | LOW — derived count |

---

### `${new_count}`

| Field | Value |
|-------|-------|
| Type | Integer |
| Description | Number of concepts encountered once (first pass complete; not yet in review cycle) |
| Written by | Dashboard calculation |
| Read by | Dashboard mastery overview |
| First produced | Onboarding Day 1 |
| Integration risk | LOW — derived count |

---

### `${retention_rate}`

| Field | Value |
|-------|-------|
| Type | Float (0.0 - 1.0, displayed as %) |
| Description | Percentage of SM-2 review exercises answered correctly in the last 14 days |
| Written by | Dashboard calculation: `correct_answers / total_review_answers` over last 14 days |
| Read by | Dashboard (Topic Selection Step 3) |
| First produced | Day 17 (14 days after first reviews appear) |
| Integration risk | MEDIUM — rolling 14-day window must be consistent; must show N/A before 14 days of review data |
| Notes | Formula must be shown in UI to avoid black-box distrust |

---

### `${review_duration}`

| Field | Value |
|-------|-------|
| Type | Integer (seconds) |
| Description | Elapsed time to complete the review queue portion of a session |
| Written by | Session timer (marks time between first exercise start and queue complete screen) |
| Read by | Queue summary panel (Daily Session Step 7); session summary |
| First produced | Daily Session Step 7 (first queue completion) |
| Integration risk | LOW — subset of `${session_duration}` |

---

### `${email_preferences}`

| Field | Value |
|-------|-------|
| Type | Object `{opted_in: Boolean, preferred_time: TimeOfDay}` |
| Description | Marcus's email delivery preferences |
| Written by | Email opt-in confirmation (Onboarding Step 10); settings page |
| Read by | Email delivery scheduler |
| First produced | Onboarding Step 10 |
| Integration risk | LOW — simple preferences; must be respected by email scheduler |
| Notes | Default: opted in, delivery at 8:00 AM; configurable post-onboarding |

---

### `${lessons_completed}`

| Field | Value |
|-------|-------|
| Type | Integer |
| Description | Total number of lessons Marcus has completed at least once |
| Written by | Lesson completion tracker (increments on first completion of each lesson) |
| Read by | Session summary; dashboard lessons progress bar |
| First produced | Onboarding Step 5 (first lesson) |
| Integration risk | LOW — simple count; deduplicated per lesson_id |

---

## Integration Risk Summary

| Risk Level | Variables | Integration Concern |
|-----------|----------|---------------------|
| HIGH | `experience_level`, `lesson_status`, `answer_result`, `sm2_score`, `sm2_interval`, `next_review_date`, `review_queue` | Core feature correctness; failures break the primary promise |
| MEDIUM | `user_email`, `sm2_ease_factor`, `session_duration`, `time_remaining`, `streak_count`, `retention_rate`, `module_progress` | User trust and habit mechanics; failures are visible and damaging |
| LOW | `user_id`, `curriculum_list`, `lesson_id`, `lesson_content`, `module_id`, `prerequisite_ids`, `exercise_id`, `explanation`, `queue_count`, `timer_seconds`, `review_duration`, `mastered_count`, `in_review_count`, `new_count`, `email_preferences`, `lessons_completed` | Infrastructure or static; failures are isolated and recoverable |

---

## Single-Source Violations to Avoid

The following patterns would create integration failures and must be prevented in design:

1. Two components both writing `${lesson_status}` independently — exactly one writer (SM-2 engine + prerequisite checker combined) must exist
2. Email queue (`${review_queue}`) built differently than app queue — must share the same queue builder logic, not duplicate it
3. `${streak_count}` incremented by both session completion and a scheduled job — exactly one writer (session completion event) must exist
4. `${sm2_interval}` stored in two places (exercise table + separate schedule table) — single source, read by the queue builder
5. `${retention_rate}` calculated differently on the dashboard vs. the email — must use a shared calculation function
