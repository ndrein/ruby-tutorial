# Requirements — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: DISCUSS — Phase 3
**Date**: 2026-03-09
**Completeness Target**: >= 0.95
**Source**: JTBD artifacts + three journey maps + DISCOVER artifacts (all four phases)

---

## Functional Requirements

### FR-1: Expert-Calibrated Curriculum

**FR-1.1** The platform shall provide exactly 25 lessons organized into 5 modules of 5 lessons each.

**FR-1.2** Module 1 shall start with Ruby-specific syntax concepts (blocks, symbols, ranges) — not with variables, data types, loops, conditionals, or OOP fundamentals.

**FR-1.3** Every lesson shall include a side-by-side comparison showing the equivalent concept in Python and Java.

**FR-1.4** Lesson content shall be completable in 5 minutes or less by an experienced developer (Python or Java background).

**FR-1.5** The platform shall ask users one question at registration: whether they have experience in another programming language. Users who select "Yes" are placed in expert mode.

**FR-1.6** Expert mode shall filter the curriculum to start at Lesson 1 (Ruby Blocks) and shall never present modules labeled "Introduction to Programming" or similar beginner scaffolding.

**FR-1.7** Lesson content shall teach Ruby-specific idioms (blocks, procs, symbols, Enumerable, pattern matching) — not generic programming concepts.

---

### FR-2: SM-2 Spaced Repetition Engine

**FR-2.1** The platform shall implement the SM-2 spaced repetition algorithm to schedule review exercises for each concept.

**FR-2.2** SM-2 parameters shall use standard initial values: ease factor = 2.5, first interval = 1 day, second interval = 6 days.

**FR-2.3** The platform shall compute a quality of response (score 0-5) for each exercise submission based on:
- Score 5: correct answer, response time < 10 seconds
- Score 4: correct answer, response time 10-25 seconds
- Score 3: correct answer, response time 25-30 seconds or user marks "hard" (`h` key)
- Score 2: correct answer after first viewing explanation (skipped then re-reviewed)
- Score 1: incorrect answer
- Score 0: timeout (30 seconds elapsed without answer) or user skips

**FR-2.4** The SM-2 ease factor (EF) shall be updated after each review using the formula: `EF' = EF + (0.1 - (5-score) * (0.08 + (5-score) * 0.02))`, clamped to a minimum of 1.3.

**FR-2.5** A score of 0, 1, or 2 shall reset the interval to 1 day (concept reviewed tomorrow).

**FR-2.6** A score of 3, 4, or 5 shall extend the interval: `I(n) = I(n-1) * EF` rounded to the nearest integer day.

**FR-2.7** After each exercise, the platform shall show the user the next scheduled review date in plain language (e.g., "This concept will be reviewed in 3 days — March 12").

**FR-2.8** The platform shall show a plain-language reason for the scheduled interval (e.g., "First exposure — short interval to confirm retention" or "Strong recall — extended to 14 days").

**FR-2.9** SM-2 parameters (ease factor, repetition count) shall NOT be exposed in the user interface — only the next review date and a plain-language explanation.

---

### FR-3: Daily Review Queue

**FR-3.1** The platform shall automatically build a daily review queue for each user containing all exercises where `next_review_date <= today`.

**FR-3.2** The daily review queue shall be built nightly (no later than 2:00 AM in the user's timezone) and shall be identical in the email and the app.

**FR-3.3** The daily review queue shall be immutable once the session starts — new exercises due today shall not be added mid-session.

**FR-3.4** If a user's review queue is empty and no new lesson is available, the platform shall not send a daily email and shall show a "Nothing due today" message in the app.

**FR-3.5** The platform shall not allow the review queue to exceed the 15-minute session cap. If more exercises are due than can fit in 15 minutes, the queue shall be capped at the exercises closest to their scheduled date (oldest due first).

**FR-3.6** When a user misses a session, overdue exercises shall remain in the queue (not discarded) and shall be prioritized in the next session's queue.

---

### FR-4: Daily Email Notification

**FR-4.1** The platform shall send a daily digest email to each opted-in user showing today's review queue.

**FR-4.2** The email subject line shall include the queue count and estimated time (e.g., "Today's Queue — 4 reviews + 1 lesson option (est. 10 min)").

**FR-4.3** The email body shall list each exercise by concept name and the optional new lesson if one is available.

**FR-4.4** The email shall include a single call-to-action link that opens the app directly to today's session start screen.

**FR-4.5** The email shall show the user's current streak count.

**FR-4.6** The email delivery time shall be configurable by the user (default: 8:00 AM in the user's local timezone).

**FR-4.7** The email shall not contain promotional content, newsletter language, or marketing copy.

**FR-4.8** Users shall be able to opt out of daily emails; opting out shall not affect their ability to use the app.

---

### FR-5: Exercise System

**FR-5.1** Every lesson shall have at least one review exercise.

**FR-5.2** Each exercise shall be completable by an experienced developer in 25-40 seconds.

**FR-5.3** The platform shall support the following exercise types: fill-in-the-blank, multiple choice, spot-the-bug, translation (Python/Java to Ruby).

**FR-5.4** Each exercise shall have a 30-second countdown timer visible to the user.

**FR-5.5** When the timer reaches 0, the exercise shall auto-advance and record the result as `timeout` (SM-2 score 0).

**FR-5.6** Every exercise shall show an explanation after submission regardless of whether the answer was correct or incorrect.

**FR-5.7** Explanations shall connect the correct answer to the Python/Java equivalent where applicable.

**FR-5.8** Fill-in-the-blank exercises shall accept an exact match or any pre-defined accepted synonyms for the correct answer.

**FR-5.9** Multiple-choice exercises shall present exactly 4 options in a consistent layout.

---

### FR-6: Keyboard Navigation

**FR-6.1** All platform interactions shall be completable without a mouse.

**FR-6.2** The platform shall implement the following keyboard map:

| Action | Key |
|--------|-----|
| Submit answer / advance | Enter |
| Skip exercise | Esc |
| Navigate down / next | j or Tab |
| Navigate up / previous | k or Shift+Tab |
| Mark exercise as hard | h |
| Mark exercise as easy | e |
| Go to dashboard | g d (sequence) |
| Go to curriculum | c |
| Start today's session | s |
| Queue lesson for next session | q |

**FR-6.3** Every interactive element (buttons, inputs, links, selectable options) shall show a visible focus state: a 2px solid ring in a color with at minimum 3:1 contrast ratio against the page background.

**FR-6.4** Keyboard shortcuts shall be consistent across all application pages — a shortcut that works on the exercise page shall have the same behavior on the dashboard and curriculum pages where applicable.

**FR-6.5** The platform shall show a keyboard shortcut reference visible on all primary screens (not hidden behind a help modal).

**FR-6.6** The platform shall not use modal keyboard shortcuts that could conflict with typing in input fields (exercise answer inputs shall capture all keystrokes when focused).

---

### FR-7: Progress Dashboard

**FR-7.1** The platform shall provide a progress dashboard showing:
- Total concepts mastered (SM-2 interval >= 30 days)
- Total concepts in review (SM-2 interval 3-29 days)
- Total new concepts (first pass complete, not yet in first review)
- Lessons completed (count and percentage of 25)
- Current streak (consecutive days with at least one exercise completed)
- Retention rate (% correct on SM-2 reviews, rolling 14 days)

**FR-7.2** The retention rate shall include a plain-language explanation of its calculation beneath the metric.

**FR-7.3** All dashboard metrics shall reflect the state after the most recently completed session (no stale data older than the last completed session).

**FR-7.4** The dashboard shall provide navigation to the curriculum overview and to today's session.

---

### FR-8: Curriculum Navigation and Prerequisite Gates

**FR-8.1** The curriculum view shall display all 25 lessons grouped into 5 modules with per-lesson status indicators.

**FR-8.2** Lesson status indicators shall be: Mastered [x], In Review [~], Available [ ], Locked [L], and Next [>].

**FR-8.3** Lesson status shall be derived from SM-2 state and prerequisite completion in real time — not from an independent status field.

**FR-8.4** A locked lesson shall show the list of prerequisite lessons and their completion status when opened.

**FR-8.5** A locked lesson detail view shall show an estimated number of daily sessions required to unlock it.

**FR-8.6** Lesson titles and module titles shall be visible even for locked lessons — only lesson content is hidden.

**FR-8.7** An available (unlocked) lesson shall provide two actions: "Start now" and "Queue for next session."

**FR-8.8** Each lesson detail card shall show: title, module, estimated time, Python/Java concept mapped, exercise type, and a brief content description.

---

### FR-9: Session Management and Hard Cap

**FR-9.1** Each daily session shall be bounded by a 15-minute hard cap.

**FR-9.2** The session start screen shall show the user's remaining time budget before any exercises begin.

**FR-9.3** The platform shall display time remaining as exercises are completed within a session.

**FR-9.4** When 1 minute or less of session budget remains, the platform shall not start a new exercise or lesson if its estimated time exceeds the remaining budget.

**FR-9.5** On session completion, the platform shall show a summary screen with: exercises completed, lessons completed, total session time, time vs. 15-minute target, and current streak.

**FR-9.6** A session is "completed" for streak purposes when at least one exercise has been submitted (not just the app opened).

**FR-9.7** The streak counter shall increment exactly once per calendar day regardless of how many sessions the user completes that day.

---

### FR-10: Onboarding

**FR-10.1** First-time registration shall require only an email address — no profile fields, name, or phone number.

**FR-10.2** After email submission, the user shall be shown exactly one question: their experience level.

**FR-10.3** Onboarding shall complete within a single session (no multi-day onboarding flow).

**FR-10.4** The first lesson shall be accessible within 3 clicks or 3 key presses from the landing page.

**FR-10.5** Onboarding shall end with the SM-2 scheduling confirmation for the first exercise, a session summary, and an email opt-in prompt.

---

## Non-Functional Requirements

### NFR-1: Performance

**NFR-1.1** The session start screen shall load within 2 seconds on a standard broadband connection.

**NFR-1.2** Lesson content shall render within 2 seconds of navigation.

**NFR-1.3** Exercise submission shall produce feedback within 500ms of pressing Enter.

**NFR-1.4** SM-2 interval calculation shall complete within 100ms of answer submission.

**NFR-1.5** The daily queue builder shall complete for a single user within 5 seconds.

---

### NFR-2: Reliability

**NFR-2.1** SM-2 state shall be persisted transactionally — no review entry shall be lost on page refresh or network interruption.

**NFR-2.2** If a session is interrupted mid-exercise, the current exercise shall be preserved and restartable from the interrupted point.

**NFR-2.3** Daily email delivery shall have a target success rate of >= 99% for opted-in users.

**NFR-2.4** The daily queue shall be idempotent — running the queue builder twice for the same day and user shall produce the same result.

---

### NFR-3: Usability

**NFR-3.1** A new user with Python or Java background shall be able to complete onboarding without reading any documentation.

**NFR-3.2** All keyboard shortcuts shall be discoverable from the UI without opening a help section.

**NFR-3.3** The SM-2 scheduling explanation shall use plain language accessible to a developer who has never heard of SM-2.

**NFR-3.4** No error message shall contain technical identifiers (user IDs, database error codes, stack traces).

---

### NFR-4: Accessibility

**NFR-4.1** All interactive elements shall have a minimum 3:1 contrast ratio between focus indicator and background (WCAG 2.1 AA for UI components).

**NFR-4.2** All informational text shall have a minimum 4.5:1 contrast ratio (WCAG 2.1 AA).

**NFR-4.3** All images and code examples shall have descriptive alt text.

**NFR-4.4** The platform shall be navigable using keyboard only, meeting WCAG 2.1 Level AA Success Criterion 2.1.1.

---

### NFR-5: SM-2 Algorithm Fidelity

**NFR-5.1** The SM-2 implementation shall conform to the published SuperMemo SM-2 algorithm specification.

**NFR-5.2** The ease factor minimum shall be clamped at 1.3.

**NFR-5.3** The ease factor maximum shall be clamped at 2.5 (upper bound).

**NFR-5.4** The initial ease factor for new concepts shall be 2.5.

**NFR-5.5** The SM-2 algorithm shall be tested with unit tests covering: first scheduling, correct-answer interval growth, incorrect-answer interval reset, ease factor bounds, and edge cases (all correct, all incorrect, alternating correct/incorrect).

---

### NFR-6: Content Integrity

**NFR-6.1** All 25 lessons shall include at least one exercise with a correct answer defined.

**NFR-6.2** All 25 lessons shall include Python and Java equivalent comparisons.

**NFR-6.3** No lesson shall contain content explaining basic programming concepts (variables, loops, conditionals, OOP fundamentals) to a developer audience.

**NFR-6.4** All code examples in lessons and exercises shall be syntactically valid Ruby (verified by a Ruby interpreter).

---

### NFR-7: Data Constraints

**NFR-7.1** The `sm2_interval` stored value shall always be a positive integer (days >= 1).

**NFR-7.2** The `sm2_ease_factor` shall always be within range [1.3, 2.5].

**NFR-7.3** The `streak_count` shall never be negative.

**NFR-7.4** The `session_duration` shall never exceed 1800 seconds (30 minutes) — sessions beyond this indicate a timer bug.

---

## Constraints

| Constraint | Source | Value |
|-----------|--------|-------|
| Daily session cap | Problem statement | <= 15 minutes |
| Lesson length cap | Problem statement | <= 5 minutes |
| Exercise duration | Problem statement | 30 seconds per exercise |
| Curriculum size | Solution testing | Exactly 25 lessons, 5 modules |
| Algorithm | Problem statement | SM-2 (published SuperMemo specification) |
| Navigation | Problem statement | Keyboard-native; fully operable without mouse |
| Focus states | Keyboard nav spec | 2px+ ring, 3:1+ contrast ratio |
| Email opt-in | Privacy | User must explicitly opt in; no auto-subscribe |
| Initial ease factor | SM-2 spec | 2.5 |
| Ease factor minimum | SM-2 spec | 1.3 |
| Review score range | SM-2 spec | 0-5 |

---

## Out of Scope (MVP)

The following are explicitly out of scope for the MVP and should not be designed for:

- Rails extension track (OPP-6; score 7; post-MVP)
- Push notifications (OPP-2 Idea 2C; post-MVP)
- Adaptive difficulty gating on demonstrated knowledge (OPP-1 Idea 1C; post-MVP)
- Weekly summary email (OPP-7 Idea 7C; post-MVP)
- Multi-user accounts or social features
- Vim-mode optional shortcut layer (OPP-4 Idea 4C; aspirational)
- Streak grace days (single missed day without streak break; post-MVP)
- Revenue model, subscriptions, or payment processing
