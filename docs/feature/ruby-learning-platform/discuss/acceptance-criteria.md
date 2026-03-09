# Acceptance Criteria — Ruby Learning Platform

All acceptance criteria are derived from UAT scenarios in user stories and journey feature files. Each criterion is testable (observable user outcome, not technical implementation).

---

## AC-01: First-Time Onboarding

Derived from: US-01, journey-onboarding.feature

| ID | Criterion | Testable? | Source Scenario |
|----|-----------|-----------|-----------------|
| AC-01-01 | Welcome screen shows assumed-knowledge checklist on first launch, before any other content | Yes — visually verifiable | Scenario: Landing screen shows expert calibration |
| AC-01-02 | No login form, account creation, or personal data is requested | Yes — element absence verifiable | Scenario: No login required |
| AC-01-03 | Pressing Enter on welcome screen goes directly to curriculum tree (no intermediate screens) | Yes — navigation step count | Scenario: No navigation needed to reach first exercise |
| AC-01-04 | Curriculum tree shows Lesson 1 as the only available lesson on first launch | Yes — status icon verifiable | Scenario: Curriculum tree shows L1 as only available |
| AC-01-05 | Every locked lesson shows a prerequisite label (e.g., "needs L1") | Yes — label presence verifiable | Scenario: Curriculum tree shows correct lock states |
| AC-01-06 | Selecting a locked lesson shows a lock screen, not an error message | Yes — screen type verifiable | Scenario: Selecting locked lesson shows lock screen |
| AC-01-07 | Lesson preview screen shows a "What this does NOT cover" section with at least one item | Yes — section presence and content | Scenario: Lesson preview shows scope |
| AC-01-08 | 30-second exercise timer starts on exercise render without any user interaction | Yes — observable timer behavior | Scenario: Exercise timer starts automatically |
| AC-01-09 | When timer expires, correct answer shown; result recorded as "missed" | Yes — answer visibility + SM-2 state | Scenario: Timer expiry shows correct answer |
| AC-01-10 | Pressing Esc on an exercise shows the answer and records result as "skipped" (not "failed") | Yes — result type verifiable in SM-2 | Scenario: User can skip without penalty |
| AC-01-11 | Correct answer feedback shows "Correct." as first word; shows Ruby-specific explanation | Yes — text content verifiable | Scenario: Correct answer shows precise explanation |
| AC-01-12 | No score, XP, badges, or points displayed on any feedback screen | Yes — element absence verifiable | Scenario: Correct answer feedback (anti-gamification) |
| AC-01-13 | Session summary shows SM-2 schedule explanation and next lesson title | Yes — text content verifiable | Scenario: First session summary initializes SM-2 |
| AC-01-14 | All actions on all onboarding screens are keyboard-accessible (no mouse required) | Yes — keyboard-only navigation test | @property: keyboard accessibility |
| AC-01-15 | Pressing Esc mid-lesson saves position; returning resumes from last completed exercise | Yes — state persistence verifiable | @property: no session data lost |

---

## AC-02: Daily Session Flow

Derived from: US-02, journey-daily-session.feature

| ID | Criterion | Testable? | Source Scenario |
|----|-----------|-----------|-----------------|
| AC-02-01 | Session dashboard renders complete plan (review count, time estimate, lesson title) within 500ms | Yes — timing measurable | Scenario: Session dashboard pre-computes plan |
| AC-02-02 | No user selection is required to start the session | Yes — zero required actions before Enter | Scenario: No selection required to begin |
| AC-02-03 | When review queue has 0 exercises, dashboard shows "all caught up" and goes directly to lesson | Yes — conditional screen content | Scenario: Empty review queue handled gracefully |
| AC-02-04 | When 18 exercises are due, only 12 are scheduled today; 6 carry to tomorrow | Yes — queue size verifiable, deferred visible | Scenario: Oversized queue is capped |
| AC-02-05 | Review exercises are presented in urgency order (most overdue first) | Yes — order verifiable by next_review_date | Scenario: Review exercises in urgency order |
| AC-02-06 | Correct answer on review extends SM-2 interval beyond current interval | Yes — interval increase verifiable | Scenario: Correct answer extends interval |
| AC-02-07 | Incorrect answer on review resets SM-2 interval to 1 day | Yes — interval = 1 verifiable | Scenario: Incorrect answer resets interval |
| AC-02-08 | Review complete screen shows "N/M (P%)" accuracy format | Yes — text format verifiable | Scenario: Review complete shows performance |
| AC-02-09 | New lesson content shows Python/Java equivalent before Ruby syntax | Yes — content order verifiable | Scenario: New lesson uses comparison format |
| AC-02-10 | Session summary shows: total exercises, duration, streak, next lesson, tomorrow's review count | Yes — all elements verifiable | Scenario: Session summary shows accurate totals |
| AC-02-11 | All SM-2 updates persisted atomically after session complete | Yes — refresh after session = state preserved | Scenario: Session persists SM-2 state |
| AC-02-12 | Session does not cut off mid-exercise at 15-minute cap | Yes — exercise completes before cap stops session | @property: session respects 15-minute cap |
| AC-02-13 | [t] from session dashboard opens topic selection without discarding session plan | Yes — topic selection opens, review count unchanged | Scenario: User can override topic |

---

## AC-03: Topic Selection

Derived from: US-03, journey-topic-selection.feature

| ID | Criterion | Testable? | Source Scenario |
|----|-----------|-----------|-----------------|
| AC-03-01 | Curriculum tree accessible via [t] from session dashboard and [c] from any screen | Yes — keyboard shortcut triggers navigation | Scenario: Curriculum tree accessible |
| AC-03-02 | Tree shows all 25 lessons with [x]/[ ]/[~] status icons reflecting current progress | Yes — icon states verifiable per lesson | Scenario: Curriculum tree shows accurate lock states |
| AC-03-03 | Modules show [COMPLETE] / [IN PROGRESS] / [LOCKED] status | Yes — module header status verifiable | Scenario: Module status derived from lesson status |
| AC-03-04 | Selecting a locked lesson shows a lock screen (not an error) | Yes — screen type verifiable | Scenario: Lock screen for locked lesson |
| AC-03-05 | Lock screen shows: why locked, target lesson topics, each prerequisite lesson's topics and completion status | Yes — all three content sections verifiable | Scenario: Lock screen shows WHY with content |
| AC-03-06 | Lock screen [Enter] navigates to first incomplete prerequisite | Yes — navigation target verifiable | Scenario: Lock screen routes to prerequisite |
| AC-03-07 | No "skip prerequisite" option exists anywhere in the UI | Yes — element absence verifiable | Scenario: No force-skip mechanism |
| AC-03-08 | [/] opens inline keyword search; tree filters to matching lessons | Yes — search functionality verifiable | Scenario: User can search by keyword |
| AC-03-09 | Completing prerequisite lesson unlocks target lesson before completion screen renders | Yes — unlock state on completion screen verifiable | Scenario: Completing prerequisite unlocks target |
| AC-03-10 | Unlock state persists after pressing Esc to save for next session | Yes — reopen platform shows lesson as available | Scenario: Unlock persists across sessions |
| AC-03-11 | SM-2 records exercises from topic-selection path with same weight as daily session | Yes — SM-2 intervals from both paths are equivalent | Scenario: SM-2 records topic-selection exercises |

---

## AC-04: Exercise Timer

Derived from: US-04

| ID | Criterion | Testable? | Source Scenario |
|----|-----------|-----------|-----------------|
| AC-04-01 | Timer starts on exercise render, not on first keypress | Yes — timer state observable before any input | Scenario: Timer starts automatically |
| AC-04-02 | Timer is visible as a progress bar with seconds remaining | Yes — visual element presence | Scenario: Timer starts automatically |
| AC-04-03 | At 0 seconds: correct answer shown, result = "missed" in SM-2 | Yes — answer display + SM-2 state | Scenario: Timer expiry |
| AC-04-04 | Tab shows a partial hint (not the full answer) exactly once per exercise | Yes — hint content + second Tab no-ops | Scenario: Hint available once per exercise |

---

## AC-05: SM-2 Review Engine

Derived from: US-05

| ID | Criterion | Testable? | Source Scenario |
|----|-----------|-----------|-----------------|
| AC-05-01 | Correct answer: new_interval = max(1, prev_interval * ease_factor) | Yes — computed value verifiable | Scenario: Correct answer increases interval |
| AC-05-02 | Incorrect answer: new_interval = 1, ease_factor -= 0.2 | Yes — both values verifiable | Scenario: Incorrect answer resets interval |
| AC-05-03 | Ease factor minimum = 1.3 (never decreases below) | Yes — 3+ incorrect answers in sequence | Scenario: Ease factor minimum enforced |
| AC-05-04 | Daily queue = exercises with next_review_date <= today, ordered most-overdue first | Yes — queue contents and order verifiable | Scenario: Daily queue contains due exercises |
| AC-05-05 | Daily cap: max 12 exercises; excess deferred to next session (high-priority) | Yes — session exercise count + deferred list | Scenario: Daily cap defers excess |
| AC-05-06 | SM-2 state survives browser refresh before session completes | Yes — refresh mid-session, state preserved | Scenario: SM-2 state persists |
| AC-05-07 | Skipped exercises are re-queued for next session; ease factor unchanged | Yes — next session queue contains skipped | Scenario: Skipped re-queued |
| AC-05-08 | "Missed" (timer expiry) is treated same as "incorrect" for SM-2 | Yes — interval reset to 1 day | Scenario: Missed = incorrect for SM-2 |
| AC-05-09 | When storage is empty on launch (no prior sessions), platform launches in first-time onboarding mode and shows "No previous progress found. Starting fresh." | Yes — testable by clearing storage before launch | Storage cleared scenario |

---

## AC-06: Lesson Content Standards

Derived from: US-06

| ID | Criterion | Testable? | Source Scenario |
|----|-----------|-----------|-----------------|
| AC-06-01 | Every lesson shows Python or Java code equivalent before Ruby syntax | Yes — content order in every lesson verifiable | Scenario: Comparison format |
| AC-06-02 | Every lesson preview has a "does not cover" section with at least one item | Yes — section presence in all 25 lessons | Scenario: does-not-cover section |
| AC-06-03 | No exercise prompt explains what a variable, loop, or basic OOP concept is | Yes — text content review across 75 exercises | Scenario: No beginner scaffolding |
| AC-06-04 | All code examples in exercises are syntactically valid (Python/Java and Ruby) | Yes — code can be parsed/executed | Scenario: Exercise code is valid |
| AC-06-05 | All 75 exercise code examples (Python/Java and Ruby) pass automated syntax validation (e.g., `ruby -c` for Ruby, `python3 -m py_compile` for Python) | Yes — automatable as CI check | Content authoring standard |

---

## AC-07: Keyboard Navigation

Derived from: US-07

| ID | Criterion | Testable? | Source Scenario |
|----|-----------|-----------|-----------------|
| AC-07-01 | j/k move cursor up/down in all list and tree views | Yes — cursor position changes | Scenario: j/k navigation |
| AC-07-02 | J/K (shift) jump between modules/sections | Yes — cursor jumps to module boundary | Scenario: J/K module jump |
| AC-07-03 | Enter selects/submits/advances on every interactive element | Yes — action triggered on Enter | Scenario: All workflows without mouse |
| AC-07-04 | Esc goes back/cancels from any screen | Yes — navigation regression verifiable | Scenario: All workflows without mouse |
| AC-07-05 | ? opens keyboard shortcut overlay; Esc closes it | Yes — overlay visibility | Scenario: ? overlay shows shortcuts |
| AC-07-06 | All interactive elements have visible focus indicators | Yes — visual inspection + WCAG audit | Scenario: Focus indicators visible |
| AC-07-07 | p opens progress dashboard from any screen | Yes — navigation triggered from any screen | Scenario: p shortcut |
| AC-07-08 | t opens topic selection from session dashboard | Yes — topic selection overlay opens | Scenario: t override |
| AC-07-09 | / opens inline search in curriculum tree | Yes — search input visible | Scenario: / search |
| AC-07-10 | Tab shows hint in exercise view (once per exercise) | Yes — hint appears on Tab | Scenario: Hint via Tab |

---

## AC-08: Lesson Tree Navigation and Prerequisite Gating

Derived from: US-08

| ID | Criterion | Testable? | Source Scenario |
|----|-----------|-----------|-----------------|
| AC-08-01 | Curriculum tree renders all 25 lessons in 5 modules within 300ms | Yes — rendering time measurable | Performance NFR |
| AC-08-02 | Completing last lesson in a module updates module status to [COMPLETE] | Yes — module status verifiable after last lesson | Scenario: Module status updates |
| AC-08-03 | prerequisite_resolver runs atomically with lesson completion | Yes — no intermediate ambiguous state | Scenario: Atomic unlock |
| AC-08-04 | Lock screen [Enter] navigates to first incomplete prerequisite (of potentially multiple) | Yes — target of navigation verifiable | Scenario: Multi-prerequisite lock screen |
| AC-08-05 | prerequisite graph is acyclic (no cycles) | Yes — graph traversal test | @property: acyclic graph |
| AC-08-06 | Lesson 1 is always available on first launch | Yes — initial state verifiable | Scenario: Initial state |

---

## AC-09: Progress Dashboard

Derived from: US-09

| ID | Criterion | Testable? | Source Scenario |
|----|-----------|-----------|-----------------|
| AC-09-01 | Dashboard shows correct lessons_complete / 25 count | Yes — count matches completed lessons | Scenario: Accurate lesson completion |
| AC-09-02 | Per-module breakdown matches per-lesson completion data | Yes — module totals = sum of lesson statuses | Scenario: Module breakdown |
| AC-09-03 | Retention score = correct SM-2 reviews / total SM-2 reviews (last 10 per lesson) | Yes — computation verifiable with known data | Scenario: Retention score from SM-2 |
| AC-09-04 | No badges, XP, levels, points, or achievement language displayed | Yes — element and text absence | Scenario: No gamification |
| AC-09-05 | [p] from any screen opens dashboard as overlay; session state preserved | Yes — state before and after p press | Scenario: Dashboard accessible anywhere |
| AC-09-06 | Streak shown as plain count (e.g., "14 days"), not as highlighted achievement | Yes — text content and absence of special styling | Scenario: No gamification |
