# User Stories — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: DISCUSS — Phase 3
**Date**: 2026-03-09
**Template**: LeanUX format with JTBD trace, domain examples (real data), and UAT scenarios

---

## Story Index

| ID | Title | Milestone | JTBD Trace | Priority |
|----|-------|-----------|------------|----------|
| US-000 | Walking Skeleton | M0 | JS-1, JS-3 | Critical |
| US-001 | Expert Onboarding | M1 | JS-1, JS-2 | Critical |
| US-002 | First Lesson Experience | M1 | JS-1 | Critical |
| US-003 | First SM-2 Scheduling | M1 | JS-3 | Critical |
| US-004 | Daily Session Start | M2 | JS-2, JS-3 | High |
| US-005 | Review Queue Execution | M2 | JS-3, JS-4 | High |
| US-006 | Session Summary and Streak | M2 | JS-2 | High |
| US-007 | SM-2 Algorithm Core | M4 | JS-3 | Critical |
| US-008 | SM-2 Interval Scheduling | M4 | JS-3 | Critical |
| US-009 | Daily Email Queue Delivery | M2 | JS-2, JS-3 | High |
| US-010 | 30-Second Exercise Timer | M5 | JS-3, JS-4 | High |
| US-011 | Exercise Feedback and Explanation | M5 | JS-1, JS-3 | High |
| US-012 | Progress Dashboard | M6 | JS-5 | Medium |
| US-013 | Retention Rate Metric | M6 | JS-5 | Medium |
| US-014 | Keyboard Navigation | M7 | JS-4 | High |
| US-015 | Focus State Visibility | M7 | JS-4 | High |
| US-016 | Lesson Content — Expert Calibration | M8 | JS-1 | Critical |
| US-017 | Lesson Detail Card | M8 | JS-1, JS-5 | High |
| US-018 | Curriculum Navigation | M3 | JS-5 | Medium |
| US-019 | Prerequisite Gate | M3 | JS-5 | Medium |
| US-020 | Session Hard Cap | M2 | JS-2 | High |

---

# US-000: Walking Skeleton

## Problem
Marcus Chen is a senior Python/Java developer joining a Ruby team. He has signed up for
the platform but has never seen whether the full system — database, SM-2 engine, and lesson
delivery — actually works end to end. There is no skeleton; nothing runs yet. The first
thing needed is proof that a user can load the app, see a lesson, submit an answer, and
have the SM-2 engine record the result.

## Who
- Marcus Chen, experienced developer | First visit, greenfield system | Needs to see the
  vertical slice work before trusting daily practice to the tool

## JTBD Trace
- JS-1: Syntax Transfer — the lesson must render real content
- JS-3: Automated Review Queue — the SM-2 must record and schedule

## Solution
A minimal end-to-end vertical slice connecting: landing page → one lesson (Lesson 1:
Ruby Blocks) → one fill-in-the-blank exercise → SM-2 records the response and schedules
the next review. All layers must be wired together and functional — no stubs, no mocked
data. This is Feature 0 and must be the first story implemented.

## Domain Examples

### 1: Happy Path — Correct Answer
Marcus opens `http://localhost:3000`. He sees the landing page. He navigates to Lesson 1.
He reads the lesson content (Ruby Blocks with Python comparison). He types "select" into
the exercise input. He presses Enter. He sees "Correct" with an explanation. The SM-2 engine
creates a review entry for exercise 1 scheduled for 3 days later. Marcus sees the next
review date on screen.

### 2: Incorrect Answer
Marcus types "filter" (Python habit) instead of "select". He presses Enter. He sees the
correct answer ("select") with explanation connecting it to Python's `filter()`. SM-2 creates
a review entry scheduled for 1 day later (score 1 = reset to 1-day interval).

### 3: Timeout
Marcus lets the timer expire (30 seconds without typing). The exercise auto-advances.
Marcus sees the correct answer and explanation. SM-2 records a score of 0 and schedules
review for tomorrow.

## UAT Scenarios (BDD)

### Scenario: Walking skeleton — correct answer end-to-end
Given the application is running on localhost
And the database has Lesson 1 (Ruby Blocks) and Exercise 1.1 seeded
When Marcus navigates to the landing page
And Marcus navigates to Lesson 1 and its exercise
And Marcus types "select" and presses Enter
Then Marcus sees "Correct" feedback with an explanation
And the database contains a review entry for Exercise 1.1 scheduled for today + 3 days
And Marcus sees the next review date displayed on screen

### Scenario: Walking skeleton — incorrect answer creates 1-day review
Given the application is running with seeded data
When Marcus types "filter" on Exercise 1.1 and presses Enter
Then Marcus sees the correct answer "select" with explanation
And the database contains a review entry for Exercise 1.1 scheduled for today + 1 day

### Scenario: Walking skeleton — timer expiry records timeout
Given the application is running with seeded data
And Marcus has opened Exercise 1.1
When 30 seconds elapse without Marcus submitting an answer
Then the exercise auto-advances
And the database records a timeout result for Exercise 1.1
And Marcus sees the correct answer "select" with explanation

## Acceptance Criteria
- [ ] Landing page loads and renders without error
- [ ] Lesson 1 content is accessible and renders with Python/Java comparison
- [ ] Exercise 1.1 input accepts keyboard entry
- [ ] Enter key submits the answer
- [ ] Correct answer returns "Correct" feedback + explanation
- [ ] Incorrect answer returns correct answer + explanation
- [ ] Timer counts down from 30 seconds and auto-advances on expiry
- [ ] SM-2 creates a review entry in the database after any submission
- [ ] Correct answer schedules review for today + 3 days
- [ ] Incorrect/timeout schedules review for today + 1 day
- [ ] Next review date is displayed to the user in plain language

## Technical Notes
- This story has no authentication — access is unprotected for the walking skeleton
- Seed data required: 1 lesson (Lesson 1 content), 1 exercise (Exercise 1.1 — fill-in-the-blank "select")
- SM-2 state table must exist and be writable before this story is testable
- This is the "tracer bullet" — implementation establishes the full technology stack

**Effort estimate**: 2-3 days (full vertical slice, greenfield)

---

# US-001: Expert Onboarding

## Problem
Marcus Chen visits the platform for the first time. He has tried executeprogram.com and
been disappointed by beginner-oriented content. Every previous learning tool has wasted
his first session on variables, loops, and "what is a function?" He is skeptical. If the
first thing he sees is beginner content, he will leave and not return.

## Who
- Marcus Chen, senior Python/Java developer | First visit | Needs immediate recognition
  that the platform is calibrated for him

## JTBD Trace
- JS-1: Syntax Transfer — content must start at the expert level immediately
- JS-2: Daily Habit — onboarding friction kills habit formation before it starts

## Solution
A minimal 4-step onboarding: (1) UVP that explicitly names what is skipped,
(2) email registration with a single field, (3) one experience confirmation question,
(4) direct entry to Lesson 1. No multi-page profiles, no guided tours, no "let's see
where you are" diagnostic quizzes.

## Domain Examples

### 1: Happy Path — Expert confirmation
Marcus visits the landing page. He reads "Ruby for people who don't need Ruby explained."
He clicks "Start" (or presses Tab + Enter). He types `marcus@example.com`. He presses Enter.
He selects "Yes — Python, Java, or similar" with `j` and presses Enter. He is routed directly
to Lesson 1: Ruby Blocks. Total: 45 seconds from landing to first lesson.

### 2: Edge Case — User selects beginner mode
Ana Folau selects "No — I'm newer to programming." The platform routes her to a different
starting point (a note that this platform is designed for experienced developers) and provides
a reference to more appropriate tools. (Ana is not the target user; the platform is honest.)

### 3: Error Case — Duplicate email
Marcus types an email already registered. He sees "This email is already registered —
log in instead?" with a login link. He is not shown an error code or database message.

## UAT Scenarios (BDD)

### Scenario: Expert mode routes user to Lesson 1 (not a beginner intro)
Given Marcus has not previously registered
When Marcus enters his email and selects "Yes — Python, Java, or similar"
Then Marcus is routed to Lesson 1: Ruby Blocks
And Marcus does not see any lesson or page titled with beginner concepts
And the experience_level is stored as "expert" in the database

### Scenario: Registration requires only email — no other fields
Given Marcus navigates to the registration form
Then Marcus sees exactly one required input field: email address
And Marcus does not see fields for name, phone, job title, or company
And Marcus can submit the form by pressing Enter

### Scenario: Duplicate email shows login prompt — not error code
Given the email "marcus@example.com" is already registered
When Marcus enters "marcus@example.com" in the registration form
Then Marcus sees: "This email is already registered — log in instead?"
And Marcus sees a login link
And Marcus does not see a database error code or raw error message

### Scenario: Full onboarding completes in under 60 seconds keyboard-only
Given Marcus starts at the landing page
When Marcus completes onboarding using only keyboard input
Then Marcus reaches Lesson 1 in 60 seconds or less
And Marcus has not been asked for any information beyond email and experience level

## Acceptance Criteria
- [ ] Registration form has exactly one required field: email address
- [ ] Experience confirmation shows exactly one question with Yes/No options
- [ ] Selecting "Yes" stores experience_level as "expert"
- [ ] Expert users are routed directly to Lesson 1 after registration
- [ ] Lesson 1 is Ruby Blocks — not a beginner intro lesson
- [ ] Duplicate email shows human-readable login prompt
- [ ] Full onboarding is completable by keyboard without mouse
- [ ] Landing page headline names what the platform skips (variables, loops, OOP)

## Technical Notes
- Authentication: email-only for MVP (no password on first visit — magic link or simple session)
- experience_level field on user record; drives curriculum routing
- No analytics tracking or session recording on onboarding flow

**Effort estimate**: 1-2 days

---

# US-002: First Lesson Experience

## Problem
Marcus has confirmed he is an expert. He is now on Lesson 1. He has seen Ruby documentation
before — dense, reference-style, no anchoring to what he already knows. He needs to learn
what blocks are without starting from zero. Without a Python/Java anchor, he will mentally
translate and get confused about semantics.

## Who
- Marcus Chen | First lesson; expert mode active | Motivated to learn quickly; intolerant
  of wasted time on known concepts

## JTBD Trace
- JS-1: Syntax Transfer — lesson must bridge from Python/Java to Ruby idiom

## Solution
A lesson view that renders: Ruby concept name, a brief conceptual explanation (no basics),
a code comparison table (Python equivalent, Java equivalent, Ruby syntax), a key insight
statement, and a "Continue to exercise" action.

## Domain Examples

### 1: Happy Path — Lesson renders with comparison
Marcus opens Lesson 1: Ruby Blocks. He sees a Python list comprehension and a Java stream
on the left; the Ruby block `lst.map { |x| x * 2 }` on the right. He reads "Key insight:
the block is not a value — it is passed to the method." In 90 seconds he understands blocks.

### 2: Edge Case — Lesson with no Java equivalent
Lesson 3 (Symbols) has no direct Java equivalent. The comparison column shows "Java: no
direct equivalent — closest is String constants." Marcus still gets the anchor he needs:
the Python side shows string interning behavior as an analogy.

### 3: Error Case — Lesson content fails to load
Network error prevents Lesson 1 from loading. Marcus sees "Lesson content unavailable —
please try again" with a retry button. The error does not show a stack trace or raw HTTP
error. His session timer has not started.

## UAT Scenarios (BDD)

### Scenario: Lesson includes Python and Java side-by-side comparison
Given Marcus opens Lesson 1: Ruby Blocks in expert mode
Then Marcus sees a side-by-side table showing:
  | Language | Syntax                           |
  | Python   | [x * 2 for x in lst]             |
  | Java     | lst.stream().map(x -> x * 2)     |
  | Ruby     | lst.map { |x| x * 2 }            |
And Marcus does not see any section explaining what a loop is

### Scenario: Lesson is completable in 5 minutes or less
Given Marcus opens Lesson 1 and reads at normal pace
When Marcus reaches the "Continue to exercise" prompt
Then less than 5 minutes have elapsed since opening the lesson

### Scenario: Lesson with no Java equivalent shows explicit "no direct equivalent" note
Given Marcus opens Lesson 3: Symbols vs Strings
Then the Java column shows "No direct equivalent" with a brief note
And Marcus sees a Python analogy for the concept instead

### Scenario: Lesson load failure shows human-readable error without timer starting
Given Lesson 1 content fails to load due to a network error
Then Marcus sees "Lesson content unavailable — please try again" with a Retry button
And Marcus does not see a stack trace or HTTP error code
And the 15-minute session timer has not started while the lesson was loading

## Acceptance Criteria
- [ ] Every lesson view includes a Python/Java side-by-side comparison table
- [ ] Lessons with no Java equivalent show "No direct equivalent" note in Java column
- [ ] Lesson content does not contain sections explaining variables, loops, or OOP basics
- [ ] Lesson is completable in 5 minutes or less
- [ ] "Continue to exercise" action is accessible via Enter key
- [ ] Lesson load failure shows a human-readable error message with retry
- [ ] Session timer does not start until the user explicitly begins the exercise

**Effort estimate**: 1-2 days

---

# US-003: First SM-2 Scheduling

## Problem
Marcus has submitted his first exercise. The platform has evaluated his answer. Now the
SM-2 engine must schedule his next review and communicate this to him in plain language.
Without this confirmation, Marcus has no reason to trust that the system is tracking his
progress — it is a black box.

## Who
- Marcus Chen | Just completed first exercise | Needs to see the system is tracking him;
  anxious about black-box automation

## JTBD Trace
- JS-3: Automated Review Queue — the trust signal for automation starts here

## Solution
After exercise submission, show an SM-2 scheduling confirmation panel with: the concept
name, a plain-language next review date ("in 3 days — March 12"), and a one-sentence
explanation of the interval reasoning. No technical parameters (ease factor, etc.) shown.

## Domain Examples

### 1: Correct Answer — First Scheduling
Marcus answers Exercise 1.1 correctly. The panel shows: "Ruby Blocks will be reviewed
in 3 days (March 12). First exposure — short interval to confirm retention." Marcus sees
a concrete date, not a raw number.

### 2: Incorrect Answer — Reset to 1 Day
Marcus answers incorrectly. The panel shows: "Ruby Blocks will be reviewed tomorrow
(March 10). Answer was incorrect — short interval for immediate reinforcement." Marcus
understands the system responded to his performance.

### 3: Timeout — Same as Incorrect
Marcus lets the timer expire. The panel shows: "Ruby Blocks will be reviewed tomorrow
(March 10). No answer submitted — short interval to try again soon." Marcus understands
the timeout was treated as "needs review."

## UAT Scenarios (BDD)

### Scenario: Correct first answer schedules review in 3 days
Given Marcus answers Exercise 1.1 (Ruby Blocks) correctly on first attempt
When the SM-2 scheduling confirmation appears
Then Marcus sees: "Ruby Blocks will be reviewed in 3 days"
And Marcus sees the calendar date (today + 3 days)
And Marcus sees the plain-language reason: "First exposure — short interval to confirm retention"
And the database has a review entry for exercise_1_1 with next_review_date = today + 3

### Scenario: Incorrect first answer schedules review tomorrow
Given Marcus answers Exercise 1.1 incorrectly
When the SM-2 scheduling confirmation appears
Then Marcus sees: "Ruby Blocks will be reviewed tomorrow"
And the database has a review entry with next_review_date = today + 1
And the reason explains: "Answer was incorrect — short interval for reinforcement"

### Scenario: SM-2 parameters are not exposed in the UI
Given Marcus has received any SM-2 scheduling confirmation
Then Marcus does not see any of: ease factor, repetition count, EF value, or raw interval integer
And Marcus only sees the next review date and plain-language reason

## Acceptance Criteria
- [ ] Correct answer on first exercise schedules review for today + 3 days
- [ ] Incorrect answer on first exercise schedules review for today + 1 day
- [ ] Timeout schedules review for today + 1 day
- [ ] Review date is shown as calendar date + relative days ("in 3 days — March 12")
- [ ] Plain-language reason explains the interval
- [ ] SM-2 parameters (EF, repetition count) are not displayed in the UI
- [ ] Database review entry exists after any exercise submission

**Effort estimate**: 1-2 days

---

# US-004: Daily Session Start

## Problem
Marcus has been using the platform for a week. He opens his email at 8:47 AM and sees
today's queue. He clicks the link. The app must present his full session agenda — review
exercises and optional lesson — before he starts, so he can commit knowing he will finish
in time for his 9:00 AM standup.

## Who
- Marcus Chen, week 1 user | 6-day streak; 13 minutes before standup | Needs to know
  the session will fit in his window before committing

## JTBD Trace
- JS-2: Daily Habit — habit requires certainty about session length
- JS-3: Automated Review Queue — queue must be visible before session starts

## Solution
A session start screen that lists today's review exercises by concept, shows an estimated
session time, shows the optional new lesson, shows remaining time budget, and accepts
Enter to begin.

## Domain Examples

### 1: Happy Path — Full queue with lesson option
Marcus opens the app. He sees: "4 review exercises (est. 4 min) + Lesson 3 option (~3 min).
Total estimated: 7 min. Budget: 15:00." He presses Enter and starts. He finishes in 11 minutes.

### 2: Edge Case — Queue only, no lesson available
Marcus has finished all available lessons. The session start screen shows only the review
queue. There is no lesson option. Marcus sees "Review queue only today — all lessons completed
or none available."

### 3: Edge Case — Empty queue
Marcus has no exercises due and no new lessons. The screen shows "Nothing due today."
His streak does not break — today was a rest day per the SM-2 schedule.

## UAT Scenarios (BDD)

### Scenario: Session start screen shows review queue before starting
Given Marcus opens the platform (from email link or directly)
When the session start screen loads
Then Marcus sees the list of review exercises by concept name
And Marcus sees the optional new lesson (if available) with estimated time
And Marcus sees his remaining time budget: 15 minutes 0 seconds
And Marcus sees his current streak count
And Marcus can start the session by pressing Enter

### Scenario: Empty queue shows rest-day message without breaking streak
Given Marcus has no exercises in his review queue for today
And no new lessons are available
When Marcus opens the platform today
Then Marcus sees "Nothing due today — you're on track"
And Marcus's streak does not break for this day

### Scenario: Session start screen shows identical queue to daily email
Given Marcus has received a daily email listing exercises A, B, C
When Marcus opens the platform from the email link
Then the session start screen shows the same exercises A, B, C in the same order
And no additional exercises have been added since the email was sent

## Acceptance Criteria
- [ ] Session start screen lists today's review exercises by concept name
- [ ] Optional new lesson is shown with estimated time if available
- [ ] Session time budget (15:00) is visible before starting
- [ ] Current streak count is displayed
- [ ] Empty queue shows human-readable rest-day message
- [ ] Email queue and app queue are identical
- [ ] Enter key starts the session from the start screen

**Effort estimate**: 1 day

---

# US-005: Review Queue Execution

## Problem
Marcus is in the review queue. He has 4 exercises. Each one needs to feel like a productive
workout — not a drag. The SM-2 scheduled exercises should feel appropriately timed: not too
obvious, not completely forgotten. The keyboard must handle all navigation. His answer must
be submitted with Enter and the next exercise must appear without friction.

## Who
- Marcus Chen, established user | Mid-session; in review queue | Needs flow state:
  no friction between exercises, keyboard-only interaction

## JTBD Trace
- JS-3: Automated Review Queue — exercises must surface at the right memory-challenge level
- JS-4: Keyboard Navigation — no mouse interaction during review flow

## Solution
Sequential exercise delivery with: exercise number/total indicator, 30-second timer,
answer input (focused by default), Enter to submit, auto-advance after feedback,
"h" to mark hard. SM-2 score computed on submission.

## Domain Examples

### 1: Happy Path — Correct answer, normal pace
Marcus is on exercise 2 of 4 (Blocks with yield). He remembers the answer after a moment
of thought. He types "yield" in 22 seconds. He presses Enter. He sees "Correct — yield calls
the block passed to the method." The exercise auto-advances after 2 seconds.

### 2: Edge Case — Marks as hard
Marcus is on exercise 4 (Comparable). He is uncertain. He presses "h" to mark as hard.
The timer pauses briefly. He types "<=>". He presses Enter. He sees "Correct." The SM-2
score is recorded as 3 (correct but marked hard), resulting in a shorter interval than
a confident correct answer.

### 3: Error Case — Timeout
Marcus is distracted during exercise 3 (attr_accessor). 30 seconds elapse. The exercise
auto-advances. He sees the correct answer and explanation. The SM-2 score is 0.

## UAT Scenarios (BDD)

### Scenario: Review exercise shows position indicator and 30-second timer
Given Marcus is in the review queue with 4 exercises
When the first exercise appears
Then Marcus sees "Review 1 of 4" as a position indicator
And Marcus sees a 30-second countdown timer
And the answer input field is focused (no tab required to start typing)

### Scenario: Correct answer advances to next exercise after feedback
Given Marcus types "yield" and presses Enter on exercise 2 of 4
When the answer is evaluated as correct
Then Marcus sees "Correct" feedback with an explanation
And Marcus sees the exercise auto-advance after 2 seconds OR can press Enter to advance immediately
And the next exercise (3 of 4) appears

### Scenario: Mark-as-hard records lower SM-2 quality score
Given Marcus presses "h" before submitting exercise 4 (Comparable)
And Marcus types "<=>" and presses Enter
When the answer is evaluated as correct
Then the SM-2 score is recorded as 3 (not 4 or 5)
And the resulting next_review_date is shorter than it would be for a score-4 correct answer

### Scenario: Full review queue completes keyboard-only
Given Marcus has 4 exercises in his review queue
When Marcus completes all 4 exercises
Then Marcus has submitted all answers with only keyboard input
And Marcus has not needed to click any button with a mouse
And each exercise input field was focused automatically without requiring Tab navigation

## Acceptance Criteria
- [ ] Exercise shows position indicator (e.g., "Review 2 of 4")
- [ ] 30-second timer is visible and counting down
- [ ] Answer input is auto-focused when exercise loads
- [ ] Enter key submits the answer
- [ ] Feedback (correct/incorrect) appears within 500ms
- [ ] Exercise auto-advances after feedback (or on Enter)
- [ ] "h" key marks exercise as hard and reduces SM-2 score
- [ ] Timer expiry auto-advances with score 0
- [ ] All 4 exercises completable without touching mouse

**Effort estimate**: 1-2 days

---

# US-006: Session Summary and Streak

## Problem
Marcus has finished his session. He needs a clear done state — a screen that confirms
what he accomplished, how much time he used, and that his streak is intact. Without this,
the session ends ambiguously and the habit reinforcement signal is missed.

## Who
- Marcus Chen, post-session | Just completed review queue + lesson | Needs a done state
  that reinforces the habit and confirms the streak

## JTBD Trace
- JS-2: Daily Habit — streak is the primary habit retention signal

## Solution
A session summary screen showing: exercises completed, lesson completed (if any), session
time vs. 15-minute target, streak count (incremented if first session today), and SM-2
updates (which concepts moved to longer intervals).

## Domain Examples

### 1: Happy Path — Under target, streak increments
Marcus finishes in 11 minutes 24 seconds. Streak was 6; now shows 7. Summary shows 4
reviews + Lesson 3 completed. Time remaining: 3 min 36 sec under target.

### 2: Edge Case — Exactly at target
Marcus finishes in exactly 15 minutes. Summary shows "Session target met." Streak increments.
No "over budget" warning — the cap did exactly its job.

### 3: Edge Case — Second session same day
Marcus, curious, opens the app again in the evening. Streak is still 7 (no double-increment).
The session start screen shows "You've already completed today's session — nothing new is due."

## UAT Scenarios (BDD)

### Scenario: Session summary shows time vs. 15-minute target
Given Marcus has completed a session in 11 minutes 24 seconds
When the session summary screen appears
Then Marcus sees "Session time: 11 min 24 sec"
And Marcus sees "Daily target: 15 min"
And Marcus sees "Under target by: 3 min 36 sec"

### Scenario: Streak increments on first session completion of the day
Given Marcus's streak is 6 days
And this is Marcus's first completed session today
When the session summary screen appears
Then Marcus sees "Streak: 7 days"

### Scenario: Streak does not double-increment on same-day second session
Given Marcus has already completed one session today (streak = 7)
When Marcus opens the app a second time today and completes exercises
Then Marcus's streak remains at 7 days
And the session summary shows "Streak: 7 days (already credited today)"

## Acceptance Criteria
- [ ] Session summary shows: exercises completed, lesson completed, session time, daily target, difference
- [ ] Session summary shows current streak count
- [ ] Streak increments by 1 on first completed session of the calendar day
- [ ] Streak does not increment on second+ session same day
- [ ] "Completed session" = at least 1 exercise submitted (not just app opened)
- [ ] Navigation shortcuts on summary: "g d" for dashboard, Esc for home

**Effort estimate**: 1 day

---

# US-007: SM-2 Algorithm Core

## Problem
The SM-2 algorithm is the engine driving the entire review schedule. Without a correct,
tested implementation, every review interval is wrong, exercises surface at wrong times,
and the tool's core value (automated retention-optimized review) fails.

## Who
- Marcus Chen via the system | The algorithm runs invisibly | Needs to surface exercises
  at the ideal memory-challenge moment (60-85% correct rate at review time)

## JTBD Trace
- JS-3: Automated Review Queue — the SM-2 is the mechanism behind the job

## Solution
Implement the published SM-2 algorithm. Inputs: previous interval, previous ease factor,
repetition count, quality of response (0-5). Outputs: new interval (days), new ease factor.
This is a pure function with deterministic outputs — fully unit-testable.

## Domain Examples

### 1: First scheduling after correct answer (quality 4)
Marcus answers Exercise 1.1 correctly at normal pace (score 4). Input: repetitions=0, EF=2.5.
Output: interval=6 days (second exposure interval), EF=2.5 (unchanged at score 4).
Wait — SM-2 spec: first interval = 1, second = 6. At repetition=1 (first review), if score>=3,
interval becomes 6. At repetition=2, I(n) = I(n-1) * EF.

### 2: Ease factor degradation after repeated difficult answers
Marcus consistently answers with quality 2 (correct but very slow). After 3 reviews:
EF degrades from 2.5 → 2.14 → 1.86 → 1.64. Interval growth slows; concept appears more
frequently. Correct behavior — Marcus is struggling with this concept.

### 3: Ease factor floor enforcement
EF has degraded to 1.32. Next quality score is 1 (incorrect). New EF formula yields 1.11
— below minimum. EF is clamped to 1.3. Interval resets to 1 day.

## UAT Scenarios (BDD)

### Scenario: First correct response schedules 1-day review
Given exercise_id=1 has never been reviewed before
And Marcus answers with quality score 4
When the SM-2 algorithm calculates the next interval
Then the interval is 1 day
And the ease factor remains 2.5

### Scenario: Second correct response schedules 6-day review
Given exercise_id=1 has been reviewed once (interval=1, repetitions=1, EF=2.5)
And Marcus answers with quality score 4 at the 1-day review
When the SM-2 algorithm calculates the next interval
Then the interval is 6 days

### Scenario: Third correct response uses EF multiplication
Given exercise_id=1 is at interval=6, repetitions=2, EF=2.5
And Marcus answers with quality score 4
When the SM-2 algorithm calculates the next interval
Then the interval is 6 * 2.5 = 15 days (rounded to nearest integer)

### Scenario: Incorrect answer resets interval to 1 day
Given exercise_id=1 is at any interval, any repetitions
And Marcus answers with quality score 1
When the SM-2 algorithm calculates the next interval
Then the interval resets to 1 day
And the repetition count resets to 0

### Scenario: Ease factor minimum is clamped at 1.3
Given exercise_id=1 has EF=1.32
And Marcus answers with quality score 1 (EF formula yields EF < 1.3)
When the SM-2 algorithm calculates the new ease factor
Then the ease factor is clamped to 1.3 exactly

## Acceptance Criteria
- [ ] First correct answer: interval = 1 day
- [ ] Second correct answer: interval = 6 days
- [ ] Nth correct answer (n>=3): interval = previous_interval * EF
- [ ] Incorrect/timeout (score < 3): interval resets to 1 day; repetitions reset to 0
- [ ] EF update formula: EF' = EF + (0.1 - (5-q)*(0.08 + (5-q)*0.02))
- [ ] EF minimum clamped to 1.3
- [ ] EF maximum clamped to 2.5
- [ ] Initial EF = 2.5 for all new exercises
- [ ] Algorithm is a pure function with no side effects (fully unit-testable)

**Effort estimate**: 1 day

---

# US-008: SM-2 Interval Scheduling

## Problem
Calculating the SM-2 interval is correct, but the interval must also be converted into
a scheduled date, stored in the database, and used to build the daily review queue.
Without the scheduling layer, the algorithm output is computed but never used.

## Who
- Marcus Chen via the system | Exercises complete; SM-2 calculated new intervals | System
  must write these to the database so the queue builder can find them

## JTBD Trace
- JS-3: Automated Review Queue — queue depends on correctly stored scheduled dates

## Solution
After each exercise submission, write the SM-2 output to a reviews table: exercise_id,
user_id, interval, ease_factor, repetition_count, next_review_date. The daily queue
builder queries this table for exercises where next_review_date <= today.

## Domain Examples

### 1: Correct answer schedules review 6 days out (second review)
Marcus reviews Exercise 2.1 for the second time and answers correctly (score 4). Previous
interval was 1 day. New interval = 6 days. next_review_date = today + 6. Database record:
`{exercise_id: 2, interval: 6, ef: 2.5, reps: 2, next_review_date: '2026-03-16'}`.

### 2: Queue builder includes exercise on scheduled date
On March 16, the nightly queue builder runs. Exercise 2.1 has `next_review_date = 2026-03-16`.
It is included in Marcus's queue. Marcus receives his email with Exercise 2.1 listed.

### 3: Missed day — exercise stays due
Marcus misses March 16 (no session). On March 17, the queue builder runs and finds
Exercise 2.1 with `next_review_date = 2026-03-16` (overdue by 1 day). It is included
in March 17's queue. Marcus completes it on March 17. SM-2 calculates the next interval
from this new completion date.

## UAT Scenarios (BDD)

### Scenario: SM-2 output is persisted to database after exercise submission
Given Marcus submits answer to Exercise 2.1 with quality score 4
When the SM-2 algorithm calculates interval = 6 days
Then a record exists in the reviews table with:
  exercise_id = 2
  user_id = marcus's user_id
  interval = 6
  next_review_date = today + 6

### Scenario: Queue builder includes exercises due today
Given it is March 16 and Exercise 2.1 has next_review_date = March 16
When the nightly queue builder runs
Then Exercise 2.1 is included in Marcus's review queue for March 16

### Scenario: Queue builder includes overdue exercises from missed days
Given Marcus missed his session on March 16
And Exercise 2.1 has next_review_date = March 16
When the queue builder runs on March 17
Then Exercise 2.1 is included in Marcus's review queue for March 17

## Acceptance Criteria
- [ ] SM-2 output is written to reviews table after every exercise submission
- [ ] next_review_date = today + new_interval (integer days)
- [ ] Queue builder selects exercises where next_review_date <= today
- [ ] Queue builder is idempotent (same result if run twice on same day)
- [ ] Overdue exercises (next_review_date in past) are included in current queue
- [ ] Queue caps at maximum exercises fitting within 15-minute budget (30 sec each = max 30 exercises; practical max ~8-10)

**Effort estimate**: 1 day

---

# US-009: Daily Email Queue Delivery

## Problem
Marcus has a preferred learning window of 8:47 AM before standup. Without an email
arriving before that window, he may not remember to open the app. The email is the
habit trigger — the cue that starts the routine. Without it, the daily practice habit
is self-directed and less reliable.

## Who
- Marcus Chen, week 1+ user | Opted in to daily email; relies on it as habit cue | Needs
  email to arrive at his configured time with the right content

## JTBD Trace
- JS-2: Daily Habit — email is the habit trigger (cue → routine → reward)
- JS-3: Automated Review Queue — email content must match the app queue

## Solution
A nightly queue builder that: (1) calculates each opted-in user's review queue for tomorrow,
(2) sends a daily digest email at the user's preferred time with queue content, estimated
time, and a single CTA link to the app session.

## Domain Examples

### 1: Happy Path — 4 review exercises, email arrives at 8:00 AM
Marcus's email arrives at 8:00 AM. Subject: "Today's Queue — 4 reviews + 1 lesson option
(est. 10 min)". Body lists concepts: Ruby Symbols, Blocks with yield, attr_accessor,
Comparable. CTA link opens the app to the session start screen. Streak shown: 6 days.

### 2: Edge Case — Empty queue, no email sent
Today, Marcus has no exercises due and no lessons available. No email is sent. Marcus
checks the app and sees "Nothing due today." His streak is not affected.

### 3: Error Case — Email delivery failure
The email service returns a failure for Marcus's address. The platform logs the error
and retries once after 15 minutes. If the second attempt fails, the platform records
delivery failure and serves the queue in-app (Marcus can still access via direct visit).
Marcus is not shown an error — the app works normally.

## UAT Scenarios (BDD)

### Scenario: Daily email arrives at user's configured time with correct queue
Given Marcus has opted in to daily email at 8:00 AM
And Marcus has 4 exercises in his review queue for today
When 8:00 AM arrives in Marcus's timezone
Then Marcus receives an email with:
  subject containing "4 reviews"
  body listing all 4 exercise concept names
  a CTA link to the session start screen
  Marcus's current streak count
And the email does not contain promotional language

### Scenario: Email and app queue are identical
Given Marcus receives a daily email listing exercises A, B, C
When Marcus clicks the CTA link and the session start screen loads
Then the session start screen lists exercises A, B, C in the same order as the email
And no exercises have been added or removed from the queue between email send and app open

### Scenario: No email is sent when queue is empty
Given Marcus has no exercises due today and no new lessons
When 8:00 AM arrives
Then Marcus does not receive a daily email
And Marcus's streak is not affected by the empty day

## Acceptance Criteria
- [ ] Email sends at user's configured delivery time (± 5 minutes)
- [ ] Email subject includes queue count and estimated time
- [ ] Email body lists all exercises by concept name
- [ ] Email CTA link opens the session start screen in the app
- [ ] Email includes current streak count
- [ ] Email does not contain promotional, newsletter, or marketing language
- [ ] Email is not sent when queue is empty
- [ ] Email queue content matches app session start screen queue exactly
- [ ] Failed delivery is retried once; failure logged; app remains functional

**Effort estimate**: 1-2 days

---

# US-010: 30-Second Exercise Timer

## Problem
Marcus has 15 minutes for his daily session. Each review exercise must be 30 seconds.
Without a timer, exercises can run long (defeating the session budget) or the user
has no urgency signal. Without auto-advance on timeout, a forgotten exercise could
block the session indefinitely.

## Who
- Marcus Chen, in exercise session | Exercises must fit 30-second budget | Needs
  structural enforcement, not personal discipline

## JTBD Trace
- JS-3: Automated Review Queue — timer enforces review session structure
- JS-4: Keyboard Navigation — timer should not interrupt keyboard flow

## Solution
A 30-second countdown timer visible on every exercise. Timer starts when the exercise
loads. On expiry, exercise auto-advances with a timeout result. User can submit early
by pressing Enter. Timer does not block or modal-interrupt typing.

## Domain Examples

### 1: Happy Path — Answer submitted in 22 seconds
Marcus types "select" in 22 seconds and presses Enter. Timer stops. `timer_seconds = 22`.
SM-2 score = 4 (correct, 10-25 seconds range).

### 2: Edge Case — Timer expires at exactly 30 seconds
Marcus is thinking and the timer reaches 0. The exercise auto-advances. Marcus sees the
correct answer. SM-2 score = 0 (timeout).

### 3: Edge Case — User presses "h" (mark hard) with 15 seconds on timer
Marcus is struggling. He presses "h" at the 15-second mark. The timer pauses at 15
(or extends by 10 seconds). Marcus types his answer and submits. SM-2 score reflects
the "hard" mark.

## UAT Scenarios (BDD)

### Scenario: Timer is visible and counts down from 30 seconds
Given Marcus has started a review exercise
When the exercise loads
Then Marcus sees a timer showing 0:30
And the timer counts down each second
And the timer is visible without scrolling on any screen size

### Scenario: Timer auto-advances exercise on expiry
Given Marcus has an exercise loaded and the timer reaches 0
When 30 seconds elapse without submission
Then the exercise auto-advances immediately
And Marcus sees the correct answer with an explanation
And the SM-2 result is recorded as "timeout" (score 0)

### Scenario: Elapsed time informs SM-2 score on submission
Given Marcus submits an answer at the 8-second mark (before 10 seconds)
Then the SM-2 score is 5 (correct + fast)
Given Marcus submits at the 18-second mark (10-25 seconds)
Then the SM-2 score is 4 (correct + normal)
Given Marcus submits at the 28-second mark (25-30 seconds)
Then the SM-2 score is 3 (correct + slow)

## Acceptance Criteria
- [ ] Timer counts down from 30 seconds on exercise load
- [ ] Timer is visible without scrolling
- [ ] Auto-advance fires at exactly 30 seconds
- [ ] Timeout result records SM-2 score 0
- [ ] Timer_seconds value at submission informs SM-2 score (5/4/3 based on ranges)
- [ ] Timer does not prevent typing in the answer input field
- [ ] "h" key marks exercise as hard and affects SM-2 score

**Effort estimate**: 1 day

---

# US-011: Exercise Feedback and Explanation

## Problem
Marcus submits an answer. Correct or incorrect, he needs to know why. A bare "Correct!"
with no context teaches nothing. A bare "Wrong" with no context is demoralizing. The
explanation after each exercise is where the actual learning is reinforced.

## Who
- Marcus Chen, post-submission | Just submitted an exercise answer | Needs feedback that
  reinforces the concept, not just a pass/fail signal

## JTBD Trace
- JS-1: Syntax Transfer — explanations must connect Ruby to Python/Java

## Solution
After every exercise submission, display: result indicator (Correct/Incorrect/Timeout),
the correct answer, and a 2-3 sentence explanation connecting the answer to Python/Java
equivalents where applicable. Never show just "Correct!" or "Wrong!" alone.

## Domain Examples

### 1: Correct Answer — Reinforcement explanation
Marcus types "select" for Exercise 1.1. Feedback: "Correct. `select` returns elements
where the block returns true — equivalent to Python's `filter()` or Java's
`stream().filter()`. Unlike Python's generator, Ruby's `select` returns an array."

### 2: Incorrect Answer — Instructive feedback
Marcus types "filter" (Python habit). Feedback: "The correct answer is `select`. Ruby's
array filtering method is `select`, not `filter`. Python developers often default to
`filter` — in Ruby, `select` is the idiomatic choice. `filter` does not exist as an
Array method in Ruby."

### 3: Timeout — Same explanation, no judgment
Timer expires. Feedback: "Time expired. The correct answer was `select`. `select` returns
elements where the block returns true — Ruby's equivalent to Python's `filter()`."
No language like "Too slow!" or "Try harder."

## UAT Scenarios (BDD)

### Scenario: Correct answer shows explanation with Python/Java connection
Given Marcus answers Exercise 1.1 correctly with "select"
When the feedback panel appears
Then Marcus sees "Correct"
And Marcus sees a 2-3 sentence explanation that includes the Python/Java equivalent
And the explanation does not contain the words "Wrong" or "Try again"

### Scenario: Incorrect answer shows correct answer and instructive explanation
Given Marcus answers Exercise 1.1 with "filter" (incorrect)
When the feedback panel appears
Then Marcus sees the correct answer "select" displayed prominently
And Marcus sees an explanation of why "select" is correct and where "filter" came from
And the feedback does not say "Wrong!" in isolation without explanation

### Scenario: Timeout shows explanation without judgment language
Given Marcus's exercise timer expires
When the feedback panel appears
Then Marcus sees "Time expired"
And Marcus sees the correct answer and explanation
And the feedback does not contain: "Too slow", "Hurry up", "Try harder", or "Failed"

## Acceptance Criteria
- [ ] Every exercise shows feedback panel after submission (correct, incorrect, or timeout)
- [ ] Correct feedback shows: "Correct" + explanation with Python/Java connection
- [ ] Incorrect feedback shows: correct answer + instructive explanation (why correct)
- [ ] Timeout feedback shows: "Time expired" + correct answer + explanation
- [ ] No feedback panel contains isolated "Wrong!" or "Incorrect!" without explanation
- [ ] Explanation references Python or Java equivalent for all fill-in-blank exercises
- [ ] Enter key on feedback panel advances to next exercise

**Effort estimate**: 1 day

---

# US-012: Progress Dashboard

## Problem
Marcus has been practicing for two weeks. He has no consolidated view of his progress.
He cannot tell if his retention is improving or stagnating. He cannot see how far through
the curriculum he is. Without a dashboard, the SM-2 engine is a black box and the habit
has no visible reinforcer beyond the streak count.

## Who
- Marcus Chen, week 2+ user | After daily session; wants to assess trajectory | Needs
  progress visibility that builds trust and motivation without being gamified

## JTBD Trace
- JS-5: Progress Visibility — dashboard is the primary artifact for this job

## Solution
A dashboard screen showing: mastery counts (Mastered/In Review/New), lessons complete,
streak, retention rate with calculation explanation, and navigation shortcuts to curriculum
and session start.

## Domain Examples

### 1: Happy Path — Week 2 state
Marcus opens the dashboard. He sees: "12 mastered, 8 in review, 4 new. 8 of 25 lessons.
14-day streak. 73% retention rate (% correct on SM-2 reviews, last 14 days)."

### 2: Edge Case — Before 14 days of review data
Marcus is on Day 10. He has not yet accumulated 14 days of SM-2 reviews. The retention
rate shows "Not enough data (available after 14 days of reviews)."

### 3: Edge Case — First day, nothing mastered yet
Marcus opens the dashboard on Day 1 after his first session. He sees: "0 mastered, 0 in
review, 1 new (Ruby Blocks). 1 lesson complete. 1-day streak."

## UAT Scenarios (BDD)

### Scenario: Dashboard shows correct mastery counts after a session
Given Marcus has 12 concepts with SM-2 interval >= 30 days
And Marcus has 8 concepts with SM-2 interval 3-29 days
And Marcus has 4 concepts with SM-2 interval 1-2 days (new/recent)
When Marcus opens the dashboard
Then Marcus sees "Mastered: 12" and "In Review: 8" and "New: 4"

### Scenario: Retention rate shows N/A before 14 days of review data
Given Marcus has been using the platform for 10 days (less than 14 days of review data)
When Marcus views the dashboard retention rate
Then Marcus sees "Retention Rate: Not enough data yet"
And Marcus sees "Available after 14 days of SM-2 reviews"

### Scenario: Dashboard metrics reflect latest completed session
Given Marcus just completed a session in which he mastered 1 new concept (interval reached 30 days)
When Marcus opens the dashboard immediately after the session
Then "Mastered" count shows the incremented value
And the dashboard does not show stale data from before the session

## Acceptance Criteria
- [ ] Dashboard shows Mastered / In Review / New concept counts derived from SM-2 state
- [ ] Dashboard shows lessons completed count (X of 25) and percentage
- [ ] Dashboard shows current streak
- [ ] Dashboard shows retention rate with calculation explanation
- [ ] Retention rate shows "Not enough data" before 14 days of review data
- [ ] All metrics reflect the state after the most recent completed session
- [ ] "c" keyboard shortcut navigates to curriculum from dashboard
- [ ] "s" keyboard shortcut navigates to today's session from dashboard

**Effort estimate**: 1 day

---

# US-013: Retention Rate Metric

## Problem
The retention rate is the key measure of whether SM-2 is working. But a raw percentage
with no explanation is opaque and untrustworthy for a developer who values precision.
Marcus will not trust a number he cannot verify or understand.

## Who
- Marcus Chen, week 2+ user | Reads the dashboard | Needs to understand how the number
  is calculated to trust it

## JTBD Trace
- JS-5: Progress Visibility — the retention rate is the outcome metric for the SM-2 job

## Solution
Display the retention rate with: the percentage, a plain-language calculation description
("Percentage of SM-2 review answers correct, last 14 days"), the raw counts if requested
(X correct out of Y total reviews), and a note when the window has insufficient data.

## Domain Examples

### 1: Sufficient Data
Marcus has completed 43 SM-2 reviews in the past 14 days. 31 were correct. Retention
rate = 31/43 = 72.1%, displayed as 72%.

### 2: Edge Case — 100% retention
Marcus has only 5 reviews in the window, all correct. Rate = 100%. This is not suspicious
— it is early-stage data. The note "based on 5 reviews" contextualizes it.

### 3: Edge Case — No reviews in window
Marcus has not completed any sessions in 14 days (exceptional case). Retention rate shows
"No reviews in past 14 days."

## UAT Scenarios (BDD)

### Scenario: Retention rate shows percentage with description
Given Marcus has 31 correct answers out of 43 total SM-2 reviews in the last 14 days
When Marcus views the dashboard retention rate
Then Marcus sees "Retention Rate: 72%"
And Marcus sees beneath it: "Percentage of SM-2 review answers that were correct, last 14 days"

### Scenario: Retention rate rounds to nearest whole percent
Given Marcus has 31 correct out of 43 (72.09...)
Then Marcus sees "72%" (rounded down, not "72.09%")

### Scenario: Low review count is contextualized with sample size note
Given Marcus has only 5 reviews in the past 14 days, all correct
When Marcus views the retention rate
Then Marcus sees "Retention Rate: 100%"
And Marcus sees "Based on 5 reviews — more data will improve accuracy"

## Acceptance Criteria
- [ ] Retention rate = correct SM-2 review answers / total SM-2 review answers, last 14 days
- [ ] Displayed as whole percentage (rounded to nearest integer)
- [ ] Plain-language calculation description shown beneath the metric
- [ ] Sample size note shown when fewer than 20 reviews in the window
- [ ] "Not enough data" shown before 14 days of review activity
- [ ] Calculation uses a rolling 14-day window (not calendar month)

**Effort estimate**: 1 day (can be combined with US-012 implementation)

---

# US-014: Keyboard Navigation

## Problem
Marcus is a vim/terminal-native developer. Every time he reaches for the mouse in a
learning session, his flow is interrupted. He has tried other tools where clicking
"Submit" required taking his hands off the keyboard. The accumulated friction of 10+
mouse interactions per session adds up to a daily irritant that reduces his motivation
to return.

## Who
- Marcus Chen | Every session, every exercise | Needs complete keyboard control;
  mouse use is a context switch that damages flow state

## JTBD Trace
- JS-4: Keyboard Navigation — the entire job is expressed through this story

## Solution
Implement the full keyboard map from the requirements. All navigation, submission, and
application-level shortcuts must work consistently across all pages. Input fields must
capture keystrokes when focused without triggering navigation shortcuts.

## Domain Examples

### 1: Full session keyboard-only
Marcus opens the app at 8:47 AM. He completes his full session — email link open, session
start, 4 review exercises, Lesson 3, exercise, session summary, dashboard navigation —
without touching the mouse once.

### 2: Edge Case — Typing "j" in an answer field
Marcus is typing the answer "JSON" into an exercise input. He types "j". This should
input the letter "j" into the field, not navigate down. When the input field is focused,
navigation shortcuts are disabled.

### 3: Edge Case — "g d" sequence on a page with text input focused
Marcus is on the dashboard (no active input). He presses "g" then "d". He is navigated to
the dashboard (if not already there). No partial command ("g" alone) causes unexpected behavior.

## UAT Scenarios (BDD)

### Scenario: Enter submits exercise from answer input field
Given Marcus is on a review exercise with the input field focused
When Marcus types his answer and presses Enter
Then the answer is submitted
And Marcus does not navigate away from the exercise without feedback appearing

### Scenario: Navigation shortcuts do not fire while input field is focused
Given Marcus is typing in an exercise answer input field
When Marcus types "j" or "k" or "h" or "e"
Then these characters are inserted into the input field
And no navigation action is triggered

### Scenario: g+d sequence navigates to dashboard from any non-input context
Given Marcus is on the exercise feedback panel (no input focused)
When Marcus presses "g" then "d"
Then Marcus navigates to the progress dashboard

### Scenario: Esc skips current exercise
Given Marcus is on a review exercise
When Marcus presses Esc
Then the exercise is skipped and recorded as skipped (SM-2 score 0)
And Marcus advances to the next exercise or queue summary

## Acceptance Criteria
- [ ] Enter submits answers on all exercise types
- [ ] j/Tab navigates down; k/Shift+Tab navigates up on selectable lists
- [ ] Esc skips exercise or cancels current action
- [ ] h marks exercise as hard
- [ ] e marks exercise as easy
- [ ] g+d navigates to dashboard
- [ ] c navigates to curriculum
- [ ] s starts today's session
- [ ] q queues current lesson for next session
- [ ] Navigation shortcuts disabled when any text input field is focused
- [ ] All shortcuts work consistently on all application pages

**Effort estimate**: 1-2 days

---

# US-015: Focus State Visibility

## Problem
Marcus can use keyboard navigation, but without visible focus states he cannot tell
which element is currently focused. This is especially critical when tabbing through
selectable options (experience confirmation, lesson selection) — if the focus ring
is invisible, keyboard navigation is effectively broken.

## Who
- Marcus Chen | Using keyboard navigation | Needs to see which element is focused
  at all times; invisible focus = effectively broken keyboard nav

## JTBD Trace
- JS-4: Keyboard Navigation — focus visibility is a prerequisite for usable keyboard nav

## Solution
Apply a visible focus ring (2px solid, color meeting 3:1+ contrast against background)
to all interactive elements: buttons, links, input fields, selectable options, navigation
items, and exercise choices.

## Domain Examples

### 1: Happy Path — Tab through exercise options
Marcus tabs through multiple-choice options on Exercise 3. Each option shows a 2px
blue ring as it gains focus. He can see exactly which option is selected before pressing Enter.

### 2: Edge Case — Dark background
The platform uses a dark theme. The default browser blue focus ring (contrast ~2:1 against
dark backgrounds) is insufficient. A custom light ring (white or accent color) meets the 3:1
contrast requirement.

### 3: Edge Case — Input field focused
Marcus clicks into the exercise answer input. A visible focus ring appears around the input
border. When he tabs to the Submit button, the ring moves to the button clearly.

## UAT Scenarios (BDD)

### Scenario: Every interactive element shows a visible focus ring when focused
Given Marcus tabs through all interactive elements on the exercise page
When each element receives focus
Then a visible 2px solid ring appears around that element
And the ring color has at minimum 3:1 contrast ratio against the surrounding background

### Scenario: Focus ring is visible on dark backgrounds
Given the platform renders on a dark background
When any interactive element receives focus
Then the focus ring uses a color with >= 3:1 contrast against the dark background
And the focus ring is not the default browser blue (which may fail contrast on dark backgrounds)

### Scenario: Focus ring on multiple-choice options
Given Marcus is on a multiple-choice exercise
When Marcus tabs through the four answer options
Then each option shows a clear focus indicator as it is focused
And Marcus can tell which option will be selected if he presses Enter

## Acceptance Criteria
- [ ] All interactive elements have custom focus styles (not default browser outline)
- [ ] Focus ring is 2px solid minimum
- [ ] Focus ring color meets 3:1 contrast against page background (light and dark themes)
- [ ] Input fields, buttons, links, selectable options all show focus ring
- [ ] Focus is not trapped on any element (Tab moves to next focusable element)
- [ ] Focus order follows logical reading order (top to bottom, left to right)

**Effort estimate**: 1 day (can be combined with US-014 implementation)

---

# US-016: Lesson Content — Expert Calibration

## Problem
The curriculum is the primary differentiator. If Lesson 1 explains what a loop is,
the platform has failed its core promise and Marcus will leave. Expert calibration is
not a preference — it is the entire value proposition.

## Who
- Marcus Chen, first-time learner | Starting Lesson 1 | Needs content that respects
  his existing knowledge and immediately anchors Ruby concepts to Python/Java

## JTBD Trace
- JS-1: Syntax Transfer — expert calibration is the mechanism for this job

## Solution
All 25 lessons must be written by an expert-calibrated author. Lesson content must:
(1) start with the Ruby-specific concept, not the generic programming concept,
(2) include a Python/Java side-by-side comparison, (3) not define variables, loops,
OOP fundamentals, or conditionals, (4) include at least one code example in valid Ruby,
(5) be completable in 5 minutes or less.

## Domain Examples

### 1: Correct Expert Content — Lesson 1 (Blocks)
Lesson opens: "Ruby blocks are anonymous code passed to methods. If you know Python's
lambdas or Java's method references, blocks are similar — but blocks are not first-class
values in the same way." Side-by-side shows Python comprehension vs. Ruby block. No
mention of "a loop repeats code."

### 2: Incorrect Content (Anti-Pattern to Avoid)
Lesson opens: "In programming, a method is a reusable piece of code. Let's start with
what methods are..." This is beginner scaffolding and violates the expert calibration
requirement. Marcus closes the tab.

### 3: Edge Case — Concept with no Python/Java equivalent
Lesson 3 (Symbols): "Ruby symbols are like immutable string identifiers — they exist
in one place in memory. Python doesn't have a direct equivalent, but string interning
is an analogy. Java developers: think of string constants or enum values."

## UAT Scenarios (BDD)

### Scenario: Lesson 1 does not contain beginner scaffolding
Given Marcus opens Lesson 1: Ruby Blocks in expert mode
Then the lesson does not contain any of:
  "In programming, ..."
  "A variable is ..."
  "A loop is ..."
  "Object-oriented programming means ..."
  "Before we start, let's review ..."

### Scenario: Every lesson includes Python and Java equivalents
Given Marcus opens any of Lessons 1-25
Then the lesson includes a comparison showing the Python equivalent
And the lesson includes the Java equivalent (or "No direct equivalent" with a note)
And the comparison is formatted in a scannable table or code block

### Scenario: Lesson code examples are syntactically valid Ruby
Given any code example in any lesson
When the code example is evaluated in a Ruby interpreter
Then no syntax errors are raised

## Acceptance Criteria
- [ ] No lesson contains text explaining basic programming concepts (variables, loops, etc.)
- [ ] Every lesson includes Python equivalent comparison
- [ ] Every lesson includes Java equivalent comparison (or explicit "no direct equivalent")
- [ ] Every code example in every lesson is syntactically valid Ruby
- [ ] All 25 lessons are completable in 5 minutes or less
- [ ] Lesson 1 begins with Ruby-specific concept (Blocks), not a beginner topic

**Effort estimate**: 2-3 days (content production — 25 lessons x ~30 min each)

---

# US-017: Lesson Detail Card

## Problem
Marcus is exploring the curriculum and wants to select the best next lesson. He needs
enough information to make an informed choice — concept name, time estimate, what it maps
to in Python/Java — without needing to open the lesson itself.

## Who
- Marcus Chen, week 2 user | On curriculum navigation; exploring lesson choices | Needs
  lesson preview without reading full content

## JTBD Trace
- JS-1: Syntax Transfer — preview must show Python/Java mapping
- JS-5: Progress Visibility — detail card surfaces lesson metadata for decision-making

## Solution
A lesson detail card (accessible from the curriculum view by pressing Enter on a lesson)
showing: title, module, status, estimated time, Python/Java concept mapped, exercise type,
and a brief one-sentence description. Two actions: "Start now" and "Queue for next session."

## Domain Examples

### 1: Available Lesson
Marcus presses Enter on Lesson 9 (Method Objects). Card shows: "Method Objects and
&method(:name). Module 2. ~4 min. Python: functools/partial. Java: Method references (::).
Exercise: fill-in-the-blank. Status: Available." He presses "q" to queue for tomorrow.

### 2: Locked Lesson
Marcus presses Enter on Lesson 15 (method_missing). Card shows: "Status: LOCKED. Requires
Lessons 11, 12, 13, 14 (3 incomplete). Complete 3 more lessons to unlock. Estimated:
2-3 daily sessions."

### 3: Mastered Lesson
Marcus presses Enter on Lesson 2 (Symbols — mastered). Card shows: "Status: Mastered.
Last reviewed: March 8. Next review: April 7 (30 days). You can re-read this lesson
any time." One action: "Read again (no exercise)."

## UAT Scenarios (BDD)

### Scenario: Available lesson card shows all required fields
Given Marcus selects Lesson 9 (Method Objects, status=Available) from the curriculum
When the lesson detail card opens
Then Marcus sees: lesson number, title, module name, estimated time, Python equivalent,
  Java equivalent, exercise type, and current status
And Marcus sees two keyboard actions: Enter (Start now) and q (Queue for next session)

### Scenario: Locked lesson card shows prerequisite list with completion status
Given Marcus selects Lesson 15 (method_missing, status=Locked)
When the lesson detail card opens
Then Marcus sees the prerequisite lessons listed with their completion status (done/not done)
And Marcus sees an estimated number of sessions to unlock
And Marcus does not see a Start button or queue option (lesson is locked)

### Scenario: Mastered lesson card shows review history
Given Marcus selects Lesson 2 (Symbols, status=Mastered)
When the lesson detail card opens
Then Marcus sees the mastered status, last reviewed date, and next review date
And Marcus sees a "Read again" option (no exercise — it's mastered)
And Marcus does not see a "Queue for next session" option (no exercise needed)

## Acceptance Criteria
- [ ] Lesson card shows: title, module, status, estimated time, Python equivalent, Java equivalent, exercise type
- [ ] Available lesson shows two actions: "Start now" (Enter) and "Queue for next session" (q)
- [ ] Locked lesson shows prerequisite list with each prerequisite's completion status
- [ ] Locked lesson shows estimated sessions to unlock
- [ ] Mastered lesson shows last reviewed date and next review date
- [ ] Mastered lesson shows "Read again" option (no exercise)
- [ ] Card closes with Esc; returns to curriculum view

**Effort estimate**: 1 day

---

# US-018: Curriculum Navigation

## Problem
Marcus wants to understand the full 25-lesson arc without feeling overwhelmed. A flat
list of 25 lessons with no structure would be hard to navigate and create a sense of
endless distance. Module grouping creates achievable milestones and a sense of position.

## Who
- Marcus Chen, week 2 user | Exploring curriculum | Needs orientation and motivation
  through visible progress at module level, not just lesson level

## JTBD Trace
- JS-5: Progress Visibility — curriculum map provides orientational progress signal

## Solution
A curriculum overview grouped into 5 modules. Each module shows: module number, name,
lesson count, and module progress indicator. Modules expand to show individual lessons.
Locked modules show titles but not content. Navigation with j/k; Enter to expand or open.

## Domain Examples

### 1: Happy Path — Week 2 curriculum state
Marcus opens the curriculum. He sees: Module 1 (5/5 complete), Module 2 (3/5 complete),
Modules 3-5 (0/5 each, locked). He can see module titles for locked modules. He can
expand Module 2 to see individual lessons.

### 2: Edge Case — All modules locked
A brand-new user opens the curriculum. Only Module 1 is available. Modules 2-5 are locked.
The user can see module titles and lesson count ("5 lessons") but not individual lesson titles
or content within locked modules (exception: module-level titles are always visible).

### 3: Edge Case — First module completed, second unlocked
Marcus completes Lesson 5 (last in Module 1). Module 2 unlocks immediately. On next page
load, Marcus sees Module 2 lessons as "Available" status.

## UAT Scenarios (BDD)

### Scenario: Curriculum shows all 5 modules with progress indicators
Given Marcus navigates to the curriculum
Then Marcus sees 5 modules with names and progress indicators:
  Module 1: Ruby Fundamentals for Polyglots (5/5 complete)
  Module 2: Ruby Methods and Blocks (3/5 complete)
  Modules 3-5: (0/5 each, locked)
And each module shows a completion percentage or fraction

### Scenario: Locked module shows title but not individual lesson details
Given Marcus views a locked module (Module 3, for example)
Then Marcus sees the module title: "Ruby Object Model"
And Marcus sees "5 lessons" as the lesson count
And Marcus does not see individual lesson titles within the locked module
And Marcus sees a note: "Complete Module 2 to unlock"

### Scenario: Completing last lesson in a module unlocks the next module
Given Marcus is on Lesson 5 (last lesson in Module 1) and completes its exercise
When Marcus returns to the curriculum view
Then Module 2 shows as unlocked (lessons show Available status)
And Marcus does not need to reload the page to see the unlock

## Acceptance Criteria
- [ ] Curriculum shows all 5 modules with module names and lesson counts
- [ ] Module progress shown as "X of 5 lessons complete" fraction
- [ ] Locked modules show module title and lesson count only (no individual lesson titles)
- [ ] Unlock of next module happens immediately after last prerequisite lesson completion
- [ ] j/k navigates between modules and lessons
- [ ] Enter expands a module or opens a lesson detail
- [ ] Esc returns to previous view

**Effort estimate**: 1 day

---

# US-019: Prerequisite Gate

## Problem
Marcus wants to jump ahead to an advanced lesson before completing the prerequisites.
Without a clear gate, he either lands in content he cannot understand (bad for learning)
or the platform silently prevents him without explanation (bad for trust). The gate must
be transparent and encourage forward progress, not just block.

## Who
- Marcus Chen, week 1-2 user | Exploring curriculum; curious about advanced content |
  Needs honest gate with clear path forward, not an opaque lock

## JTBD Trace
- JS-5: Progress Visibility — the gate teaches Marcus about the learning path structure

## Solution
When Marcus opens a locked lesson, show: (1) the lock status prominently, (2) a list of
prerequisite lessons with their current completion status, (3) an estimate of how many
sessions it will take to unlock, (4) a suggested next step (earliest available prerequisite).

## Domain Examples

### 1: Happy Path — Clear gate with path forward
Marcus tries to open Lesson 15 (method_missing). He sees it requires Lessons 11-14.
Lessons 11-14 are all incomplete. Estimate: "3 sessions." Suggested: "Start Lesson 11 first."

### 2: Edge Case — Partially met prerequisites
Marcus has completed Lessons 11 and 12. He tries to open Lesson 15. He sees: Lesson 11 (done),
Lesson 12 (done), Lesson 13 (not done), Lesson 14 (not done). Estimate: "2 more sessions."
The gate shows forward progress, not just a wall.

### 3: Edge Case — Single prerequisite
Lesson 10 (Enumerable) requires only Lesson 9. Marcus has not done Lesson 9. Gate shows:
"Requires Lesson 9: Method Objects (not completed). 1 session." Clear and minimal.

## UAT Scenarios (BDD)

### Scenario: Locked lesson shows prerequisite list with individual status
Given Marcus opens Lesson 15 which requires Lessons 11, 12, 13, 14
And Marcus has completed Lessons 11 and 12 but not 13 and 14
When the lesson detail view opens
Then Marcus sees a prerequisite list:
  Lesson 11: Completed
  Lesson 12: Completed
  Lesson 13: Not completed
  Lesson 14: Not completed
And Marcus sees "2 more prerequisites needed — approximately 2 sessions"

### Scenario: Prerequisite gate links to the suggested next lesson
Given Marcus is viewing a locked lesson with incomplete prerequisites
When Marcus reads the prerequisite gate
Then Marcus sees a suggested action: "Start Lesson [X] next" (earliest incomplete prerequisite)
And Marcus can navigate to that lesson by pressing Enter on the suggestion

### Scenario: Gate updates immediately when a prerequisite is completed mid-session
Given Marcus completes Lesson 13 during a session
When Marcus returns to the Lesson 15 detail view
Then Lesson 13 is now shown as "Completed" in the prerequisite list
And the estimate updates: "1 more prerequisite needed — approximately 1 session"

## Acceptance Criteria
- [ ] Locked lesson shows "LOCKED" status clearly
- [ ] Locked lesson shows list of all prerequisites with completed/not-completed status
- [ ] Locked lesson shows estimate of remaining sessions to unlock
- [ ] Locked lesson shows suggested next available prerequisite lesson
- [ ] Prerequisite status updates immediately when a prerequisite is completed
- [ ] No lesson content is shown for locked lessons
- [ ] Gate view is navigable by keyboard (Enter to follow suggestion, Esc to return)

**Effort estimate**: 1 day

---

# US-020: Session Hard Cap

## Problem
Marcus's core constraint is 15 minutes. If the platform allows sessions to run long by
starting exercises that cannot finish in time, Marcus loses his morning session within
his standup window. The 15-minute cap must be structural (enforced by the platform),
not behavioral (relies on Marcus stopping himself).

## Who
- Marcus Chen | Late in a session; under 2 minutes of budget remaining | Needs the
  platform to stop gracefully, not let him overrun

## JTBD Trace
- JS-2: Daily Habit — structural enforcement makes the habit sustainable

## Solution
Track session_duration in real time. When time_remaining < estimated time for the next
item (exercise ~30 sec, lesson ~5 min), do not start it. Show "Session target reached"
message. Mark the session as complete for streak purposes.

## Domain Examples

### 1: Hard cap prevents new lesson when only 2 minutes remain
Marcus has completed his review queue. He has 2 minutes 15 seconds remaining. The platform
offers Lesson 3 (estimated 3 minutes). The platform warns: "Only 2:15 remaining — Lesson 3
needs ~3 min. Session complete for today."

### 2: Hard cap prevents additional exercise when 20 seconds remain
Marcus is working through a long review queue. He has 20 seconds remaining. The platform
does not start the next exercise. Queue summary shows: "Queue truncated — session target
reached. 2 exercises deferred to tomorrow."

### 3: Edge Case — User wants to continue past the cap
Marcus deliberately wants to exceed the cap today. There is no "override" option. The cap
is structural. If Marcus wants more content, he can visit the curriculum view and read a
lesson without an active session timer.

## UAT Scenarios (BDD)

### Scenario: Platform does not start new lesson when remaining budget is less than lesson estimate
Given Marcus has 2 minutes 10 seconds remaining
And the next lesson is estimated at 3 minutes
When the queue summary screen appears
Then Marcus does not see a "Start Lesson" option
And Marcus sees "Session target nearly reached — no time for a lesson today"
And the session is marked complete for streak purposes

### Scenario: Platform truncates review queue at 15-minute boundary
Given Marcus has 25 seconds of session budget remaining
And there is 1 exercise remaining in the review queue
When the platform evaluates whether to start the next exercise
Then the exercise is deferred to tomorrow's queue
And Marcus sees "Session target reached — 1 exercise deferred to tomorrow"

### Scenario: No override option exists for the 15-minute cap
Given Marcus's session has hit the 15-minute cap
When Marcus looks for a way to continue the session
Then Marcus sees no "Continue anyway" or "Override limit" option
And the session is complete

## Acceptance Criteria
- [ ] Session timer tracks elapsed time continuously from session start
- [ ] Platform does not start a new lesson when remaining budget < lesson estimate
- [ ] Platform does not start a new exercise when remaining budget < 30 seconds
- [ ] Deferred exercises appear in next session's queue (not discarded)
- [ ] Session marked complete for streak when cap is reached
- [ ] No override mechanism exists for the cap
- [ ] Hard cap is 900 seconds (15 minutes) exactly

**Effort estimate**: 1 day
