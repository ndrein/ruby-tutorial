# User Stories — Ruby Learning Platform

Persona: **Ana Folau** — senior Python/Java developer learning Ruby, daily 15-minute sessions.
Job stories: JS-01 through JS-06 (see jtbd-job-stories.md)

---

## US-01: First-Time Onboarding

**Job Story**: JS-01 (Daily Syntax Fluency Practice)
**MoSCoW**: Must Have
**Size**: 2 days | 5 UAT scenarios
**Status**: Ready

### Problem
Ana is a senior Python developer who has been assigned to a Ruby-on-Rails project. She opens a new learning tool and immediately braces for the usual patronizing experience — explaining what a variable is, what OOP is, why loops are useful. She cannot afford to waste time she does not have, and she will abandon any tool that does not immediately respect her existing expertise.

### Who
- Senior developer (Python/Java) with 5+ years experience
- Opening a new learning tool for the first time
- Has 5 minutes before first real session begins

### Solution
An onboarding flow that explicitly signals expert calibration on screen 1 (assumed knowledge list), shows the curriculum tree on screen 2, shows a lesson preview on screen 3, and delivers the first exercise on screen 4 — all without login, account creation, or wizard steps.

### Domain Examples
1. **Happy path**: Ana opens the platform. Screen 1 shows "This tool assumes you know: OOP, control flow, data structures." She presses Enter. Curriculum tree shows L1 available, L2-25 locked. She presses Enter on L1, sees a preview with topics and "does NOT cover: what a variable is." She presses Enter, completes 3 exercises in 4 minutes. Session summary shows SM-2 initialized. Total elapsed: 5 minutes.
2. **Curiosity path**: Ana sees the curriculum tree and navigates to L7 (locked). Lock screen explains: "Requires L6. Here is what L6 covers, here is what L7 covers." She presses Esc, goes back, selects L1 properly.
3. **Mid-lesson Esc**: Ana starts L1, completes 2 of 3 exercises, then presses Esc. Returns tomorrow; resumes from exercise 3 of 3 (not exercise 1).

### UAT Scenarios (BDD)
See: `journey-onboarding.feature`

Key scenarios:
- Landing screen shows assumed-knowledge list, no login
- Curriculum tree shows L1 available, L2-25 locked with prerequisites
- Lesson preview shows topics covered and NOT covered
- Exercise timer starts automatically (30s)
- Timer expiry auto-shows correct answer
- First session summary initializes SM-2

### Acceptance Criteria
- [ ] Welcome screen shows assumed-knowledge checklist on first launch
- [ ] No login or account creation required
- [ ] Curriculum tree shows L1 as only available lesson on first launch
- [ ] All locked lessons show prerequisite labels
- [ ] Lesson preview shows covered and explicitly-not-covered topics
- [ ] 30-second exercise timer starts automatically on exercise render
- [ ] Timer expiry shows correct answer; records as "missed" in SM-2
- [ ] Esc during exercise skips it (not fails it); answer shown
- [ ] Session summary shows SM-2 explanation and next lesson title
- [ ] All actions keyboard-accessible; no mouse required

### Technical Notes
- Single-user: no authentication layer needed
- SM-2 must initialize on first session completion, not first launch
- Onboarding assumed-knowledge list sourced from `config/onboarding.yml` (not hardcoded)
- Lesson position saved on Esc for resume

### Dependencies
- US-08 (Lesson Tree) — curriculum tree render
- US-04 (Exercise Timer) — 30-second timer
- US-05 (SM-2 Engine) — SM-2 initialization after first session

---

## US-02: Daily Session Flow

**Job Story**: JS-01, JS-03, JS-04
**MoSCoW**: Must Have
**Size**: 2 days | 6 UAT scenarios
**Status**: Ready

### Problem
Ana opens the platform each morning before standup. She has 15 minutes. She does not want to decide what to study — she wants the system to have already figured that out. Currently her ad-hoc approach (reading docs, skimming blogs) produces no retention and no structure.

### Who
- Developer who has completed at least one lesson
- Opening the platform for a daily session
- Has a hard 15-minute time budget

### Solution
A session dashboard that pre-computes today's plan: SM-2 review queue size + next available lesson. User presses Enter to start. Review runs first, then lesson. Session ends at 15 minutes (never mid-exercise). Summary shows what was done and what tomorrow looks like.

### Domain Examples
1. **Standard day**: Ana opens platform. Dashboard shows: "Review: 6 exercises (~3 min). New lesson: L5 Array Methods (~4 min). Total: ~7 min." She presses Enter. Reviews complete. Lesson completes. Summary: "14-day streak. Next: L6." Total: 7 minutes.
2. **Missed days**: Ana opens after 3 missed days. Dashboard shows: "18 reviews due. Today: 12. Tomorrow: 6." She presses Enter. 12 reviews complete. Lesson loads. Session ends normally.
3. **Empty queue**: Ana is ahead; queue is 0. Dashboard shows: "All caught up. Today: L5 only." She presses Enter. Goes straight to lesson.

### UAT Scenarios (BDD)
See: `journey-daily-session.feature`

### Acceptance Criteria
- [ ] Session dashboard renders pre-computed plan within 500ms of opening
- [ ] Dashboard shows review count, time estimate, lesson title, total time estimate
- [ ] No user selection required to start session
- [ ] Review queue runs before new lesson (always)
- [ ] Daily review cap enforced: max 12 exercises or 6 minutes
- [ ] Deferred exercises appear first in tomorrow's queue
- [ ] Session does not cut off mid-exercise at time cap
- [ ] Session summary shows: exercise count, duration, streak, next lesson, tomorrow's queue
- [ ] All SM-2 state persisted atomically on session complete
- [ ] [t] from dashboard opens topic selection overlay

### Technical Notes
- Session plan must be computed once at open, cached for session (BR-12)
- SM-2 daily computation must complete within 200ms
- Streak increments after state persists (not before)

### Dependencies
- US-05 (SM-2 Engine)
- US-08 (Lesson Tree) — next_lesson resolver
- US-04 (Exercise Timer)

---

## US-03: Topic Selection

**Job Story**: JS-01, JS-02, JS-05
**MoSCoW**: Should Have
**Size**: 2 days | 5 UAT scenarios
**Status**: Ready

### Problem
Ana is reviewing a PR that uses Ruby blocks heavily. She needs to understand blocks NOW — not in 3 days when SM-2 would naturally schedule it. She wants to navigate to blocks directly, understand what stands in her way, and get there with minimum friction.

### Who
- Developer with an immediate work need for a specific Ruby concept
- Has completed some but not all prerequisite lessons
- Triggered by external context (PR review, code review assignment)

### Solution
A curriculum tree view (accessible via [t] from session dashboard or [c] from any screen) showing all lessons with lock/unlock states. Selecting a locked lesson shows a lock screen that explains the prerequisite educationally. Lock screen navigates to prerequisite. Completing prerequisite unlocks target lesson.

### Domain Examples
1. **One prerequisite**: Ana needs L7 (Blocks). L6 is the only prereq. Lock screen shows L7 topics, L6 topics. Ana completes L6 (4 min), L7 unlocks, Ana starts L7 (5 min). Total: 9 minutes.
2. **Search**: Ana types [/] "block". Tree filters to L7 and L8. She selects L7. Same lock flow.
3. **Already available**: Ana selects L6 which is already available. Goes directly to lesson (no lock screen).

### UAT Scenarios (BDD)
See: `journey-topic-selection.feature`

### Acceptance Criteria
- [ ] Curriculum tree accessible via [t] from session dashboard and [c] from any screen
- [ ] Tree shows all 25 lessons with [x] / [ ] / [~] status icons
- [ ] Tree shows module-level status ([COMPLETE] / [IN PROGRESS] / [LOCKED])
- [ ] Selecting a locked lesson shows educational lock screen (not an error)
- [ ] Lock screen shows target lesson topics AND prerequisite lesson topics
- [ ] Lock screen shows per-prerequisite completion status
- [ ] No force-skip mechanism exists
- [ ] [/] opens inline keyword search filtering the tree
- [ ] SM-2 records exercises from topic-selection path with same weight as daily sessions
- [ ] Unlock state persists across sessions (no re-locking)

### Technical Notes
- prerequisite_resolver runs atomically with lesson completion (BR-10)
- Search filter is client-side (25 lessons fits in memory)
- Curriculum tree reachable from any screen; must not break session-in-progress state

### Dependencies
- US-08 (Lesson Tree) — prerequisite graph
- US-05 (SM-2 Engine) — exercise recording

---

## US-04: Exercise Timer

**Job Story**: JS-04 (Session Length Discipline)
**MoSCoW**: Must Have
**Size**: 1 day | 3 UAT scenarios
**Status**: Ready

### Problem
Without a time cap, exercises expand to fill available attention. A "quick" exercise becomes a 3-minute deliberation. Ana needs each exercise to take exactly 30 seconds — forcing quick recall rather than extended reasoning.

### Who
- Any user completing any exercise
- Context: review exercise or lesson exercise

### Solution
A 30-second countdown timer visible on every exercise screen. Timer starts on render. At expiry, correct answer shown automatically. User's non-answer recorded as "missed" for SM-2.

### Domain Examples
1. **Normal use**: Ana sees exercise, types answer in 12 seconds, submits. Timer stops. Normal feedback.
2. **Slow recall**: Ana is thinking. Timer hits 0. Answer appears. "Time — here is the answer." SM-2 records missed.
3. **Hint used**: Ana presses Tab at 20 seconds. Hint shown. Timer continues. Ana submits at 28 seconds.

### UAT Scenarios (BDD)

```gherkin
Scenario: Timer starts automatically on exercise render
  Given Ana is on any exercise screen
  When the exercise loads
  Then a 30-second countdown timer is visible and counting down
  And no user action is required to start the timer

Scenario: Timer expiry shows correct answer automatically
  Given Ana has not submitted an answer
  When the 30-second timer expires
  Then the correct answer is displayed automatically
  And a label "Time." appears before the answer
  And Ana's result is recorded as "missed" in SM-2
  And the next exercise loads after 3 seconds

Scenario: Hint is available once per exercise
  Given Ana is on an exercise with the timer running
  When she presses Tab
  Then a hint is shown (does not reveal the full answer)
  And the hint slot for this exercise is consumed (Tab does nothing on second press)
  And the timer continues running
```

### Acceptance Criteria
- [ ] Timer starts on exercise render, not on first keypress
- [ ] Timer shows as visual progress bar with seconds remaining
- [ ] At 0 seconds: correct answer shown automatically, result = "missed"
- [ ] Tab shows a partial hint (not full answer) once per exercise
- [ ] Timer continues after hint is shown
- [ ] User can submit answer at any point before timer expires

### Technical Notes
- Timer is purely presentational; SM-2 result recording is in US-05
- Timer state does not persist across navigation — new exercise = fresh 30s

### Dependencies
- None (standalone component)

---

## US-05: SM-2 Review Engine

**Job Story**: JS-03 (Automated Daily Review Queue)
**MoSCoW**: Must Have
**Size**: 2 days | 6 UAT scenarios
**Status**: Ready

### Problem
Ana cannot reliably self-manage what to review. Human memory decays on a curve; she will over-review recent content and neglect material from 2 weeks ago. Without an automated scheduler, she either re-reads everything (inefficient) or skips reviews entirely (no retention).

### Who
- Any user who has completed at least one exercise
- The SM-2 engine runs in the background; it is not directly operated

### Solution
Implement the SM-2 spaced repetition algorithm. Each exercise has an ease factor, current interval, and next review date. After each answer, the algorithm updates these values. Each session, compute exercises due today. Store state durably.

### Domain Examples
1. **Correct answer on first review (2 days after learning)**: ease_factor=2.5, interval=1. Answer correct. new_interval = max(1, 1 * 2.5) = 2.5 → 3 days. new next_review_date = today + 3 days.
2. **Incorrect answer after 4 days**: ease_factor=2.5, interval=4. Answer incorrect. new_interval = 1, ease_factor = 2.3. new next_review_date = tomorrow.
3. **Daily queue computation**: Ana opens platform. SM-2 finds 6 exercises with next_review_date <= today. These 6 are today's queue. 2 more are due tomorrow. These 2 are not in today's queue.

### UAT Scenarios (BDD)

```gherkin
Scenario: Correct answer increases SM-2 interval
  Given an exercise with ease_factor 2.5 and current_interval 2 days
  And Ana submitted a correct answer
  When SM-2 updates the exercise
  Then the new interval is 5 days (2 * 2.5)
  And the ease_factor remains 2.5
  And next_review_date is today + 5 days

Scenario: Incorrect answer resets SM-2 interval
  Given an exercise with ease_factor 2.5 and current_interval 6 days
  And Ana submitted an incorrect answer
  When SM-2 updates the exercise
  Then the new interval is 1 day
  And the ease_factor is 2.3 (decreased by 0.2)
  And next_review_date is tomorrow

Scenario: Ease factor minimum enforced
  Given an exercise with ease_factor 1.4
  And Ana submitted an incorrect answer 3 times in a row
  When SM-2 updates the exercise after the 3rd incorrect answer
  Then the ease_factor is 1.3 (minimum, not lower)

Scenario: Daily queue contains exactly due exercises
  Given 8 exercises have next_review_date <= today
  And 4 exercises have next_review_date > today
  When the session dashboard computes today's queue
  Then the queue contains exactly 8 exercises
  And the 4 future exercises are not included

Scenario: Daily cap defers excess reviews to next session
  Given 18 exercises are due today
  When the session starts
  Then today's queue contains 12 exercises
  And the 6 deferred exercises have their next_review_date unchanged
  And tomorrow's queue will include them as highest-priority

Scenario: SM-2 state persists across browser refresh
  Given Ana has completed 3 review exercises
  And the page is refreshed before session completes
  When the platform reloads
  Then the 3 completed exercises retain their updated intervals
  And the remaining review queue is unchanged
```

### Acceptance Criteria
- [ ] SM-2 implements standard algorithm: correct → interval * ease_factor, incorrect → interval=1, ef-=0.2
- [ ] Ease factor minimum enforced at 1.3
- [ ] Daily queue = exercises with next_review_date <= today, ordered by urgency (most overdue first)
- [ ] Daily cap = 12 exercises or 6 minutes (whichever comes first), excess deferred
- [ ] Skipped exercises: re-queued for next session, ease factor unchanged
- [ ] SM-2 state persists durably (survives browser refresh)
- [ ] SM-2 updates atomic per exercise (no partial update states)

### Technical Notes
- SM-2 state stored locally (IndexedDB or localStorage) — no server needed for MVP
- Exercise result types: correct | incorrect | skipped | missed (timer expiry)
- "Partial" removed from MVP — all non-correct submitted answers are treated as "incorrect" for SM-2 (simpler, conservative, reduces UI complexity)
- "Skipped" (Esc key) maps to re-queue, no interval change
- "Missed" (timer expiry, 0s) maps to incorrect (interval reset to 1 day)
- Storage cleared scenario: if storage is empty on launch, platform starts in first-time onboarding mode; shows "No previous progress found. Starting fresh."

### Dependencies
- US-04 (Exercise Timer) — provides "missed" result type

---

## US-06: Lesson Content Standards

**Job Story**: JS-02 (Transfer Syntax Knowledge from Python/Java)
**MoSCoW**: Must Have
**Size**: 3 days (content authoring) | 4 UAT scenarios
**Status**: Ready

### Problem
Every Ruby learning resource explains concepts from scratch. For Ana, explaining "what is a method" before showing `def greet(name)` is insulting. She needs content that starts from Python/Java equivalents and maps directly to Ruby — not content that teaches her to program.

### Who
- Experienced developer (Python/Java) learning Ruby-specific syntax
- Context: any lesson or exercise

### Solution
All 25 lessons follow a "Python/Java → Ruby" comparison format. Each lesson has: a Python/Java equivalent code block, the Ruby form, and an explanation of what is specifically different. Each lesson explicitly states what it does NOT cover (to reassure Ana nothing foundational is hidden).

### Domain Examples
1. **Lesson 1**: "In Python: `def greet(name): return f'Hello, {name}'`. In Ruby: `def greet(name); \"Hello, \#{name}\"; end`. Differences: #{} not f-string, implicit return, end keyword not indentation."
2. **Lesson 7 (Blocks)**: "In Python, you pass callables. In Ruby, you pass blocks — anonymous code chunks. Python: `items.sort(key=lambda x: x.value)`. Ruby: `items.sort_by { |x| x.value }`."
3. **Lesson 11 (Classes)**: "Python uses `def __init__`: Ruby uses `initialize`. Python uses `self.name =`: Ruby uses `@name =`. No `self` parameter in Ruby methods."

### UAT Scenarios (BDD)

```gherkin
Scenario: Every lesson shows a Python or Java equivalent before Ruby syntax
  Given any lesson in the curriculum
  When the lesson content loads
  Then a Python or Java code example appears before the Ruby form
  And the explanation focuses on what is different in Ruby (not what it does)

Scenario: Every lesson has an explicit "does not cover" section
  Given any lesson in the curriculum
  When the lesson preview loads
  Then a "What this does NOT cover" section is present
  And that section lists at least one foundational concept not included

Scenario: No lesson explains what a variable, loop, or basic OOP concept is
  Given any exercise in the curriculum
  When the exercise prompt is rendered
  Then the prompt does not include "a variable is..." or "OOP stands for..."
  And the prompt assumes knowledge of the Python/Java equivalent concept

Scenario: Exercise prompts use real Ruby code, not pseudocode
  Given any exercise
  When the exercise prompt loads
  Then the Python/Java example is valid, runnable Python or Java code
  And the expected Ruby answer is valid, runnable Ruby code
```

### Acceptance Criteria
- [ ] All 25 lessons authored in Python/Java → Ruby comparison format
- [ ] All lessons have a "does not cover" section
- [ ] No lesson or exercise uses the word "variable" or "OOP" as a teaching concept
- [ ] All code examples in exercises are syntactically valid
- [ ] Lesson metadata includes: title, module, duration_estimate, topics_covered, topics_not_covered, exercises[]

### Technical Notes
- Content stored as structured data (YAML or database), not markdown prose
- Content authoring is the primary time cost of this story (3 days)
- Content review: all 25 lessons × 3 exercises = 75 exercises to author and validate

### Dependencies
- US-08 (Lesson Tree) — for lesson metadata schema

---

## US-07: Keyboard Navigation

**Job Story**: JS-05 (Keyboard-Native Navigation)
**MoSCoW**: Must Have
**Size**: 2 days | 4 UAT scenarios
**Status**: Ready

### Problem
Ana uses vim, tmux, and keyboard shortcuts for all professional work. Mouse-dependent learning tools break her flow state. She has rated keyboard-native navigation as importance 7/10, with current satisfaction at 2/10 (ad-hoc learning tools are mouse-centric).

### Who
- Developer who uses keyboard-native tools professionally
- Context: all screens in the application

### Solution
Consistent keyboard shortcuts throughout the application following vim conventions: j/k for navigation, Enter to select/advance, Esc to back out, / for search, ? for help. All focus states visible. No action requires a mouse.

### Domain Examples
1. **Daily session**: Ana opens platform, presses Enter to start, answers exercises with keyboard, presses Enter to advance, presses Enter at session complete to exit. Zero mouse interactions.
2. **Topic selection**: Ana presses [c] to open curriculum, j/k to navigate, / to search, Enter to select, Esc to return.
3. **Help overlay**: Ana forgets shortcut, presses ?, sees full shortcut reference, presses Esc to dismiss.

### UAT Scenarios (BDD)

```gherkin
Scenario: All primary workflows complete without mouse
  Given Ana is on any screen
  Then every primary action is reachable via keyboard
  And no modal, dropdown, or interactive element requires a mouse click to operate

Scenario: j/k navigation works in all list views
  Given Ana is in the curriculum tree
  When she presses "j" five times
  Then the cursor moves down 5 lessons
  When she presses "k" three times
  Then the cursor moves up 3 lessons

Scenario: ? overlay shows all keyboard shortcuts
  Given Ana is on any screen
  When she presses "?"
  Then a keyboard shortcut reference overlay appears
  And all shortcuts are listed with their action descriptions
  When she presses Esc
  Then the overlay closes and she returns to where she was

Scenario: Focus indicators visible on all interactive elements
  Given any screen with interactive elements
  When Ana tabs through the interface
  Then every focused element shows a visible focus indicator
  And the indicator is clearly distinguishable (not browser default grey outline)
```

### Acceptance Criteria
- [ ] j/k navigation in all list/tree views
- [ ] J/K (shift) for jumping between sections
- [ ] Enter to select/submit/advance on every interactive element
- [ ] Esc to go back/cancel from any screen
- [ ] / to open inline search in curriculum tree
- [ ] ? to show keyboard shortcut overlay from any screen
- [ ] p to open progress dashboard from any screen
- [ ] t to open topic selection from session dashboard
- [ ] n to start next lesson from session complete
- [ ] Tab to show hint in exercise view
- [ ] All focus indicators visible (WCAG 2.2 AA minimum)
- [ ] No action requires a mouse

### Technical Notes
- Keyboard shortcut map defined in single config file
- Shortcuts must not conflict with browser defaults (e.g., avoid Ctrl+R, Ctrl+W)
- Focus management: after modal/overlay closes, return focus to triggering element

### Dependencies
- All UI stories (US-01 through US-09) must comply with keyboard nav specs

---

## US-08: Lesson Tree Navigation and Prerequisite Gating

**Job Story**: JS-01, JS-02, JS-06
**MoSCoW**: Must Have
**Size**: 3 days | 6 UAT scenarios
**Status**: Ready

### Problem
Ana wants to understand the full curriculum at a glance, see what is locked and why, and navigate towards specific topics when work demands it. A flat list of lessons gives no sense of what unlocks what. Arbitrary "locked" gates without explanation feel opaque and frustrating.

### Who
- Developer at any point in the curriculum
- Context: planning next steps, responding to work needs, tracking progress

### Solution
A 25-lesson curriculum tree rendered as a navigable list, organized by module. Each lesson shows completion status. Locked lessons show prerequisite labels. Selecting a locked lesson opens an educational lock screen explaining the prerequisite chain and what content covers what.

### Domain Examples
1. **Module completion view**: Ana has finished Module 1. Curriculum tree shows Module 1 [COMPLETE], Module 2 [IN PROGRESS] with L6 available and L7-10 locked. She can immediately see her position.
2. **Multi-prerequisite lock screen**: Ana selects L10 (requires L8 and L9). Lock screen shows L8 (complete), L9 (not complete). Enter navigates to L9.
3. **Search**: Ana types [/] "regex". L25 "Regex" appears. It is locked. Lock screen shows the prerequisite chain needed.

### UAT Scenarios (BDD)
See: `journey-topic-selection.feature`

Additional:
```gherkin
Scenario: Completing last lesson in a module updates module status to COMPLETE
  Given Ana has completed Lessons 1-4
  When she completes Lesson 5
  Then Module 1 status changes to [COMPLETE]
  And Module 2 status changes to [IN PROGRESS]
  And Lesson 6 status changes from [~] locked to [ ] available

Scenario: Prerequisite resolver runs atomically with lesson completion
  Given Ana has just completed the last exercise in Lesson 6
  When the lesson complete screen renders
  Then Lesson 7 is already shown as unlocked on the unlock screen
  And opening the curriculum tree shows Lesson 7 as available
  And there is no intermediate state where Lesson 7 is ambiguous
```

### Acceptance Criteria
- [ ] Curriculum tree renders all 25 lessons organized by 5 modules
- [ ] Module-level status: [COMPLETE] / [IN PROGRESS] / [LOCKED]
- [ ] Lesson-level status: [x] complete / [ ] available / [~] locked
- [ ] Locked lessons show inline prerequisite labels
- [ ] Lock screen shows: reason locked, target lesson topics, prerequisite topics, per-prerequisite status
- [ ] Lock screen [Enter] navigates to first incomplete prerequisite
- [ ] Prerequisite resolver runs atomically with lesson completion
- [ ] Module status updates immediately after last lesson in module completes
- [ ] Keyword search filters tree inline (client-side)
- [ ] Lesson 1 always shows as available on first launch

### Technical Notes
- Prerequisite graph is a DAG stored in `db/curriculum/prerequisites.yml`
- prerequisite_resolver = function(progress_state, prerequisite_graph) → available_lessons
- Must be acyclic (enforced at content authoring time, validated on load)
- All 25 lessons fit in memory for client-side filtering

### Dependencies
- US-06 (Lesson Content) — lesson metadata schema

---

## US-09: Progress Dashboard

**Job Story**: JS-06 (Progress Visibility Without Gamification)
**MoSCoW**: Must Have
**Size**: 1 day | 4 UAT scenarios
**Status**: Ready

### Problem
Ana wants to know where she actually stands in her Ruby learning — not a gamified score, but real retention data. How many lessons has she completed? How well is she retaining the concepts SM-2 has reviewed? How many sessions until she finishes the curriculum?

### Who
- Developer who has completed at least one lesson
- Context: checking progress between sessions or when planning

### Solution
A progress dashboard showing: lessons complete / total, per-module progress bars, SM-2 retention scores per completed lesson, streak (days with completed session), and an estimate of sessions remaining to curriculum completion.

### Domain Examples
1. **After Module 1**: Dashboard shows "5/25 lessons complete. Module 1: 5/5. Module 2: 0/5." Retention: L1=90%, L2=85%, L3=75%, L4=95%, L5=80%. Streak: 14 days.
2. **Low retention on one lesson**: L3 shows 40% (Ana keeps getting symbols wrong). Dashboard surfaces L3 prominently. No panic language — just information.
3. **Progress estimate**: "At your current pace (1 lesson/day), remaining 20 lessons ≈ 20 sessions."

### UAT Scenarios (BDD)

```gherkin
Scenario: Progress dashboard shows accurate lesson completion
  Given Ana has completed Lessons 1-5 and none others
  When she opens the progress dashboard
  Then she sees "5/25 lessons complete"
  And Module 1 shows "5/5" progress
  And all other modules show "0/N" progress

Scenario: Retention score derived from SM-2 data
  Given Lesson 3 exercises have been reviewed 10 times in total
  And 6 of those reviews were answered correctly
  When Ana views the progress dashboard
  Then Lesson 3 shows a retention score of 60%
  And the score is labeled as "SM-2 retention (last 10 reviews)"

Scenario: No gamification elements are shown
  Given Ana has completed 5 lessons with 90% average retention
  When she views the progress dashboard
  Then no badges, XP, levels, or achievement notifications are shown
  And no congratulatory language beyond factual completion counts is shown
  And streak is shown as a plain number ("14 days") not highlighted as achievement

Scenario: Progress dashboard accessible from any screen
  Given Ana is in the middle of a session
  When she presses "p"
  Then the progress dashboard opens as an overlay
  And session state is preserved
  When she presses Esc
  Then the overlay closes and session state is intact
```

### Acceptance Criteria
- [ ] Dashboard shows: lessons complete / 25, per-module breakdown, retention per completed lesson
- [ ] Retention score = correct answers / total SM-2 reviews for that lesson's exercises (last 10)
- [ ] Streak shown as plain count, not highlighted achievement
- [ ] No XP, badges, levels, points, or achievement language
- [ ] Accessible via [p] from any screen as overlay
- [ ] Sessions remaining estimate shown (at current pace)
- [ ] Dashboard renders from SM-2 + progress_tracker data, no separate aggregate tables

### Technical Notes
- Retention computation: per-lesson, last 10 SM-2 reviews (or all reviews if < 10)
- Streak: consecutive calendar days with at least one completed session
- "Sessions remaining" estimate: pending_lessons / avg_lessons_per_session (rolling 7-day average)

### Dependencies
- US-05 (SM-2 Engine)
- US-08 (Lesson Tree)

---

## US-10: Daily Email / Notification (Post-MVP)

**Job Story**: JS-03 (Automated Daily Review Queue)
**MoSCoW**: Won't Have (MVP)
**Size**: 2 days | 3 UAT scenarios
**Status**: Draft

### Problem
Ana sometimes forgets to open the platform. A daily notification (email or browser) at her preferred time would act as a habit reinforcer without requiring her to remember.

### Who
- Developer who has set up a preferred notification time
- Context: external habit reinforcement

### Solution
Optional daily email or browser notification at a user-configured time. Notification shows: number of exercises due, next lesson title. Links directly to session start.

### Note
Deferred post-MVP. Single-user tool; email requires an email service (infrastructure cost). Browser notifications are simpler but not critical for MVP when the user is already self-motivated. Revisit after 30-day MVP validation.

### Dependencies
- US-05 (SM-2 Engine) — review count
- US-02 (Daily Session Flow) — session entry point
