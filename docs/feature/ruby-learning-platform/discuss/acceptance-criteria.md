# Acceptance Criteria — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: DISCUSS — Phase 3
**Date**: 2026-03-09
**Format**: Given/When/Then (BDD) for all testable criteria; derived directly from user stories

---

## AC-000: Walking Skeleton

### AC-000-01: Landing page loads
```gherkin
Given the application is deployed and running
When a user navigates to the root URL
Then the landing page renders within 2 seconds
And the page contains the headline or UVP text
And no server error is returned
```

### AC-000-02: Lesson 1 renders with seeded content
```gherkin
Given the database has Lesson 1 (Ruby Blocks) seeded
When a user navigates to the Lesson 1 URL
Then the lesson title "Ruby Blocks" is displayed
And the lesson body content is rendered
And a Python/Java side-by-side comparison is visible
And no error page is shown
```

### AC-000-03: Exercise accepts keyboard input
```gherkin
Given a user is on Exercise 1.1 (fill-in-the-blank)
When the exercise page loads
Then the answer input field is present
And the input field is focused automatically
And a user can type characters into the field using keyboard
```

### AC-000-04: Correct answer persists SM-2 entry with 3-day interval
```gherkin
Given a user is on Exercise 1.1
When the user types "select" and presses Enter
Then a review record is created in the database
And the record has next_review_date = today + 3 days
And the record has sm2_interval = 3
And the user sees "Correct" feedback on screen
```

### AC-000-05: Incorrect answer persists SM-2 entry with 1-day interval
```gherkin
Given a user is on Exercise 1.1
When the user types an incorrect answer and presses Enter
Then a review record is created in the database
And the record has next_review_date = today + 1 day
And the record has sm2_interval = 1
And the user sees the correct answer and explanation
```

### AC-000-06: Timer expiry triggers auto-advance and records timeout
```gherkin
Given a user is on Exercise 1.1 with the timer running
When 30 seconds elapse without the user submitting an answer
Then the exercise auto-advances immediately
And a review record is created with result = "timeout"
And the record has sm2_interval = 1
And the user sees the correct answer and explanation
```

---

## AC-001: Expert Onboarding

### AC-001-01: Registration requires email only
```gherkin
Given a new user navigates to the registration page
When the registration form renders
Then exactly one required field is visible: email address
And no fields are present for: name, phone, job title, company, or password
```

### AC-001-02: Expert mode confirmed via single question
```gherkin
Given a new user has submitted their email address
When the experience confirmation step renders
Then exactly one question is shown to the user
And two selectable options are present:
  "Yes — Python, Java, or similar"
  "No — I'm newer to programming"
And the user can select using keyboard navigation (j/k) and confirm with Enter
```

### AC-001-03: Selecting "Yes" routes to Lesson 1 — Ruby Blocks
```gherkin
Given a new user selects "Yes — Python, Java, or similar"
And the user presses Enter to confirm
When the platform processes the selection
Then the user is routed to Lesson 1
And Lesson 1 is titled "Ruby Blocks" (not a beginner intro topic)
And experience_level = "expert" is stored in the user record
```

### AC-001-04: Duplicate email shows login prompt
```gherkin
Given the email "marcus@example.com" is already registered
When a user submits "marcus@example.com" in the registration form
Then the user sees a message: "This email is already registered"
And a login link is presented
And no database error code or stack trace is visible
```

### AC-001-05: Onboarding completable keyboard-only in under 60 seconds
```gherkin
Given a user starts at the landing page
When the user completes the full onboarding flow using only keyboard input
Then the user reaches Lesson 1 in 60 seconds or less
And no mouse interaction was required at any step
```

---

## AC-002: First Lesson Experience

### AC-002-01: Lesson includes Python/Java side-by-side comparison
```gherkin
Given an expert-mode user opens any lesson (Lessons 1-25)
When the lesson content renders
Then a side-by-side comparison is visible showing:
  Python equivalent syntax
  Java equivalent syntax (or "No direct equivalent" note)
  Ruby syntax
```

### AC-002-02: Lesson does not contain beginner content
```gherkin
Given an expert-mode user opens Lesson 1: Ruby Blocks
When the lesson content is rendered
Then the content does not contain any of the following:
  "In programming, ..."
  "A variable is ..."
  "A loop is ..."
  "Let's start with the basics"
  "Object-oriented programming means"
```

### AC-002-03: Lesson loads within 2 seconds
```gherkin
Given a user navigates to any lesson URL
When the page request completes
Then the lesson content is fully rendered within 2 seconds
```

### AC-002-04: Lesson content failure shows human-readable error
```gherkin
Given lesson content fails to load due to a network or server error
When the lesson view renders
Then the user sees "Lesson content unavailable — please try again"
And a Retry button is visible and functional
And no stack trace, HTTP error code, or raw error message is shown
And the 15-minute session timer has not started
```

---

## AC-003: First SM-2 Scheduling

### AC-003-01: Correct first answer schedules review in 3 days
```gherkin
Given a user answers an exercise correctly for the first time (quality score >= 4)
When the SM-2 scheduling calculation runs
Then a review record is created with next_review_date = today + 3 days
And the scheduling confirmation screen shows "in 3 days" with the calendar date
```

### AC-003-02: Incorrect first answer schedules review tomorrow
```gherkin
Given a user answers an exercise incorrectly (quality score <= 2)
When the SM-2 scheduling calculation runs
Then a review record is created with next_review_date = today + 1 day
And the scheduling confirmation screen shows "tomorrow" with the calendar date
```

### AC-003-03: SM-2 technical parameters are not shown in the UI
```gherkin
Given a user has just completed an exercise
When the SM-2 scheduling confirmation screen is shown
Then the screen does not display any of:
  ease factor value (e.g., "2.5")
  repetition count
  interval in raw number without date
  "EF" or "SM-2 score" labels
And the screen shows only: concept name, next review date, plain-language reason
```

### AC-003-04: Plain-language reason matches scheduling rationale
```gherkin
Given a user answered correctly on first attempt
When the SM-2 scheduling confirmation appears
Then the reason reads: "First exposure — short interval to confirm retention"
Given a user answered incorrectly
When the SM-2 scheduling confirmation appears
Then the reason reads: "Answer was incorrect — short interval for reinforcement"
```

---

## AC-004: Daily Session Start

### AC-004-01: Session start screen shows full review queue before starting
```gherkin
Given Marcus has 4 exercises in today's review queue
When Marcus opens the platform (via email link or direct visit)
Then the session start screen shows all 4 exercises by concept name
And the estimated total session time is shown
And the remaining time budget (15:00) is shown
And the current streak count is shown
```

### AC-004-02: Email queue and app queue are identical
```gherkin
Given Marcus has received a daily email listing exercises A, B, C, D
When Marcus opens the platform from the email CTA link
Then the session start screen shows exercises A, B, C, D in the same order
And no exercises have been added to or removed from the queue
```

### AC-004-03: Empty queue shows rest-day message without breaking streak
```gherkin
Given Marcus has no exercises due and no new lessons available
When Marcus opens the platform today
Then Marcus sees "Nothing due today — you're on track"
And Marcus's streak count has not decreased
```

---

## AC-005: Review Queue Execution

### AC-005-01: Exercise shows position indicator and timer on load
```gherkin
Given Marcus starts the review queue with 4 exercises
When the first exercise loads
Then Marcus sees a position indicator showing "Review 1 of 4"
And a 30-second countdown timer is visible
And the answer input field is focused without requiring Tab
```

### AC-005-02: Enter submits answer and feedback appears within 500ms
```gherkin
Given Marcus has typed his answer in the exercise input field
When Marcus presses Enter
Then answer feedback (Correct/Incorrect) appears within 500ms
```

### AC-005-03: Mark-as-hard (h) records lower SM-2 score
```gherkin
Given Marcus is on exercise 4 of 4
When Marcus presses "h" to mark the exercise as hard
And Marcus types a correct answer and presses Enter
Then the SM-2 score recorded is 3 (not 4 or 5)
And the resulting next_review_date is shorter than for a score-4 correct answer
```

### AC-005-04: All review exercises completable keyboard-only
```gherkin
Given Marcus has 4 exercises in his review queue
When Marcus completes all 4 exercises
Then Marcus has not been required to click any element with a mouse
And all answer inputs were focused automatically
And Enter submitted each answer
```

---

## AC-006: Session Summary and Streak

### AC-006-01: Session summary shows time vs. target
```gherkin
Given Marcus has completed a session in 11 minutes 24 seconds
When the session summary screen appears
Then the following data is displayed:
  "Session time: 11 min 24 sec"
  "Daily target: 15 min"
  "Under target by: 3 min 36 sec"
```

### AC-006-02: Streak increments on first daily session
```gherkin
Given Marcus's streak is 6 days
And this is Marcus's first completed session today (at least 1 exercise submitted)
When the session summary appears
Then "Streak: 7 days" is displayed
And the streak value in the database has been incremented to 7
```

### AC-006-03: Streak does not double-increment on same-day second session
```gherkin
Given Marcus has already completed one session today (streak = 7)
When Marcus completes a second session on the same calendar day
Then the session summary shows "Streak: 7 days"
And the streak value in the database remains 7
```

### AC-006-04: Minimum completion for streak credit
```gherkin
Given Marcus opens the app and submits exactly 1 exercise
When Marcus closes the app without doing anything else
Then today's session counts as completed for streak purposes
Given Marcus opens the app but submits 0 exercises (only reads)
Then today's session does not count as completed for streak purposes
```

---

## AC-007: SM-2 Algorithm Core

### AC-007-01: First correct response schedules 1-day interval
```gherkin
Given exercise_id=1 has zero prior reviews (repetitions=0, EF=2.5)
When SM-2 algorithm receives quality score 4
Then output interval = 1 day
And output ease_factor = 2.5 (unchanged)
And output repetitions = 1
```

### AC-007-02: Second correct response schedules 6-day interval
```gherkin
Given exercise_id=1 has been reviewed once (repetitions=1, interval=1, EF=2.5)
When SM-2 algorithm receives quality score 4
Then output interval = 6 days
And output repetitions = 2
```

### AC-007-03: Third correct response uses EF multiplication
```gherkin
Given exercise_id=1 is at repetitions=2, interval=6, EF=2.5
When SM-2 algorithm receives quality score 4
Then output interval = round(6 * 2.5) = 15 days
And output repetitions = 3
```

### AC-007-04: Incorrect answer resets to 1-day interval
```gherkin
Given exercise_id=1 is at any interval and any repetitions value
When SM-2 algorithm receives quality score 1
Then output interval = 1 day
And output repetitions = 0
```

### AC-007-05: EF updates per formula and clamps at 1.3 minimum
```gherkin
Given exercise_id=1 has EF=1.35
When SM-2 algorithm receives quality score 1
And the EF formula yields 1.15 (below minimum)
Then output ease_factor = 1.3 (clamped to minimum)
```

### AC-007-06: EF formula is correct for quality score 5
```gherkin
Given exercise_id=1 has EF=2.5
When SM-2 algorithm receives quality score 5
Then new EF = 2.5 + (0.1 - 0 * (0.08 + 0)) = 2.5 + 0.1 = 2.6
But EF maximum is 2.5, so output ease_factor = 2.5 (clamped to maximum)
```

---

## AC-008: SM-2 Interval Scheduling

### AC-008-01: SM-2 output is persisted after every submission
```gherkin
Given a user submits any answer to any exercise
When the SM-2 algorithm calculates the new interval
Then a record exists in the reviews table containing:
  exercise_id (matching the completed exercise)
  user_id (matching the current user)
  interval (in days, positive integer)
  next_review_date (today + interval)
  ease_factor (float in range [1.3, 2.5])
  repetitions (non-negative integer)
```

### AC-008-02: Queue builder includes all exercises due today or overdue
```gherkin
Given exercise A has next_review_date = today
And exercise B has next_review_date = yesterday (overdue)
And exercise C has next_review_date = tomorrow (not yet due)
When the queue builder runs for today
Then the queue contains exercise A and exercise B
And the queue does not contain exercise C
```

### AC-008-03: Queue builder is idempotent
```gherkin
Given the queue builder runs at 2:00 AM for a user
When the queue builder runs again at 2:15 AM for the same user
Then the resulting queue is identical to the first run
And no duplicate entries are created
```

---

## AC-009: Daily Email Queue Delivery

### AC-009-01: Email arrives at configured delivery time
```gherkin
Given Marcus has set his email delivery time to 8:00 AM
And Marcus has exercises in today's review queue
When 8:00 AM arrives in Marcus's configured timezone
Then Marcus receives exactly one daily digest email
And the email was not sent before 7:55 AM
And the email was sent no later than 8:05 AM
```

### AC-009-02: Email subject includes queue count and time estimate
```gherkin
Given Marcus has 4 exercises in his review queue
And an optional lesson is available
When the daily email is sent
Then the email subject contains: "4 reviews" and "lesson option"
And the subject does not exceed 100 characters
```

### AC-009-03: Email does not contain promotional content
```gherkin
Given Marcus receives his daily email
When the email body is examined
Then the body does not contain any of:
  "newsletter"
  "unsubscribe from marketing"
  "promotional"
  "special offer"
  "upgrade"
And the only CTA link points to the session start URL
```

### AC-009-04: No email sent when queue is empty
```gherkin
Given Marcus has no exercises due today
And no new lessons are available
When 8:00 AM arrives
Then no email is sent to Marcus's address
```

### AC-009-05: Email delivery failure is handled gracefully
```gherkin
Given the email service returns a delivery error for Marcus's address
When the platform processes the delivery failure
Then the platform logs the error with timestamp and user_id
Then the platform retries once after 15 minutes
And Marcus's app session is unaffected (app works normally)
And Marcus is not shown an error message related to email failure
```

---

## AC-010: 30-Second Exercise Timer

### AC-010-01: Timer displays and counts down from 30 seconds
```gherkin
Given an exercise has just loaded
When Marcus views the exercise
Then a timer displays "0:30"
And the timer decrements by 1 second each second
And the timer is visible within the primary viewport without scrolling
```

### AC-010-02: Timer auto-advances at 30 seconds
```gherkin
Given Marcus is on an exercise and has not submitted
When the timer reaches 0:00
Then the exercise auto-advances within 1 second
And the result is recorded as "timeout"
And the SM-2 score is 0
And Marcus sees the correct answer with explanation
```

### AC-010-03: SM-2 score reflects response time
```gherkin
Given Marcus submits a correct answer at elapsed time t seconds
When t < 10 seconds
Then SM-2 score = 5
When 10 <= t < 25 seconds
Then SM-2 score = 4
When 25 <= t <= 30 seconds
Then SM-2 score = 3
```

---

## AC-011: Exercise Feedback and Explanation

### AC-011-01: Correct answer shows explanation with cross-language reference
```gherkin
Given Marcus submits a correct answer to Exercise 1.1 (Ruby Blocks)
When the feedback panel renders
Then the panel shows "Correct" or equivalent positive indicator
And the panel shows a 2-3 sentence explanation
And the explanation mentions the Python or Java equivalent
```

### AC-011-02: Incorrect answer shows correct answer and instructive explanation
```gherkin
Given Marcus submits an incorrect answer to Exercise 1.1
When the feedback panel renders
Then the panel shows the correct answer prominently
And the panel shows an explanation of why the correct answer is correct
And the explanation does not contain: "Wrong!", "Incorrect!" in isolation
And the explanation connects the correct answer to Python/Java equivalent
```

### AC-011-03: Timeout feedback uses non-judgmental language
```gherkin
Given the exercise timer expires on Exercise 1.1
When the feedback panel renders
Then the panel shows "Time expired" or equivalent neutral indicator
And the panel shows the correct answer and explanation
And the panel does not contain any of: "Too slow", "Hurry up", "Failed", "Time's up!"
```

---

## AC-012: Progress Dashboard

### AC-012-01: Dashboard shows correct mastery counts from SM-2 state
```gherkin
Given Marcus has:
  12 exercises with sm2_interval >= 30 days
  8 exercises with sm2_interval 3-29 days
  4 exercises with sm2_interval 1-2 days
When Marcus opens the progress dashboard
Then the dashboard shows "Mastered: 12"
And the dashboard shows "In Review: 8"
And the dashboard shows "New: 4"
```

### AC-012-02: Dashboard shows lessons completed with fraction
```gherkin
Given Marcus has completed 8 of 25 lessons
When Marcus opens the dashboard
Then the dashboard shows "8 of 25 lessons (32%)"
```

### AC-012-03: Retention rate unavailable before 14 days of data
```gherkin
Given Marcus has been using the platform for 10 days
When Marcus views the dashboard retention rate
Then the retention rate shows "Not enough data yet"
And a note reads "Available after 14 days of SM-2 reviews"
```

### AC-012-04: Dashboard keyboard shortcuts work
```gherkin
Given Marcus is on the dashboard
When Marcus presses "c"
Then Marcus navigates to the curriculum view
When Marcus presses "s"
Then Marcus navigates to the session start screen
```

---

## AC-013: Retention Rate Metric

### AC-013-01: Retention rate formula and display
```gherkin
Given Marcus has 31 correct answers out of 43 total SM-2 reviews in the past 14 days
When Marcus views the dashboard
Then the retention rate displays as "72%"
And beneath the metric Marcus sees: "Percentage of SM-2 review answers correct, last 14 days"
```

### AC-013-02: Small sample size is contextualized
```gherkin
Given Marcus has fewer than 20 SM-2 reviews in the past 14 days
When Marcus views the retention rate
Then the retention rate is calculated and displayed
And a note reads "Based on [N] reviews — more data will improve accuracy"
```

---

## AC-014: Keyboard Navigation

### AC-014-01: Enter submits answer
```gherkin
Given Marcus is on an exercise with the input field focused
And Marcus has typed his answer
When Marcus presses Enter
Then the answer is submitted
And Marcus sees the feedback panel
```

### AC-014-02: Navigation shortcuts disabled while input field is focused
```gherkin
Given Marcus is typing in an exercise answer input field
When Marcus types the letter "j"
Then the letter "j" is inserted into the input field
And Marcus does not navigate down to the next item
When Marcus types the letter "h"
Then the letter "h" is inserted into the input field
And the exercise is not marked as hard
```

### AC-014-03: g+d sequence navigates to dashboard
```gherkin
Given Marcus is on any page with no input field focused
When Marcus presses "g" then "d" in sequence
Then Marcus navigates to the progress dashboard
```

### AC-014-04: All keyboard shortcuts work consistently
```gherkin
Given Marcus is on any application page
When Marcus uses any defined keyboard shortcut
Then the shortcut produces the same action as documented
And no shortcut is context-dependent in an undiscoverable way
```

---

## AC-015: Focus State Visibility

### AC-015-01: All interactive elements have visible focus rings
```gherkin
Given Marcus is on any application page
When Marcus presses Tab to cycle through all focusable elements
Then each element shows a visible focus ring when focused
And no element loses its focus indicator while focused
```

### AC-015-02: Focus ring meets 3:1 contrast requirement
```gherkin
Given the application renders on its default background color
When any interactive element is focused
Then the focus ring color has a contrast ratio >= 3:1 against the surrounding background
As measured by WCAG 2.1 contrast calculation
```

### AC-015-03: Focus order follows logical reading order
```gherkin
Given Marcus is on the exercise page
When Marcus presses Tab repeatedly
Then focus moves: answer input field → submit button → skip option → hard/easy markers
And the Tab order matches the visual reading order (top to bottom, left to right)
```

---

## AC-016: Lesson Content — Expert Calibration

### AC-016-01: No beginner scaffolding in any lesson
```gherkin
Given any lesson (Lessons 1-25) is rendered
When the lesson content is inspected
Then the content does not contain:
  Definitions of variables, loops, or conditionals
  The phrase "In programming, ..."
  Explanations of what a function or method is in general
```

### AC-016-02: All lesson code examples are valid Ruby
```gherkin
Given any code example from any lesson
When the code is evaluated by a Ruby 3.x interpreter (with test-appropriate setup)
Then no syntax errors are raised
```

### AC-016-03: All lessons readable in 5 minutes or less
```gherkin
Given any lesson is opened
When a user with developer background reads the lesson at normal pace
Then the reading time does not exceed 5 minutes
```

---

## AC-017: Lesson Detail Card

### AC-017-01: Available lesson card shows all required metadata
```gherkin
Given Marcus selects an available lesson from the curriculum view
When the lesson detail card opens
Then Marcus sees: lesson number, title, module name, estimated time
And Marcus sees: Python equivalent (concept), Java equivalent (concept)
And Marcus sees: exercise type (fill-in-the-blank, multiple choice, etc.)
And Marcus sees: status "Available"
And Marcus sees two actions: "Start now" (Enter) and "Queue for next session" (q)
```

### AC-017-02: Locked lesson card shows prerequisite details
```gherkin
Given Marcus selects a locked lesson from the curriculum view
When the lesson detail card opens
Then Marcus sees the status "LOCKED"
And Marcus sees each prerequisite lesson with its completion status
And Marcus sees an estimated number of sessions to unlock
And Marcus does not see a "Start now" or "Queue" action
```

---

## AC-018: Curriculum Navigation

### AC-018-01: Curriculum shows all 5 modules with progress fractions
```gherkin
Given Marcus navigates to the curriculum view
When the view loads
Then Marcus sees all 5 modules listed
And each module shows: module name, "X of 5 lessons" fraction
And modules with no completed lessons show "0 of 5"
```

### AC-018-02: Locked modules show title but not lesson details
```gherkin
Given a module is locked (prerequisites not met)
When Marcus views the curriculum
Then the module title is visible
And the lesson count is visible ("5 lessons")
And individual lesson titles within the locked module are NOT shown
And a note explains what is needed to unlock the module
```

### AC-018-03: Module unlocks immediately after last prerequisite lesson
```gherkin
Given Marcus completes the last required lesson to unlock Module 3
When Marcus returns to the curriculum view (or refreshes)
Then Module 3 shows as unlocked with individual lessons now visible
And the lessons show Available status
```

---

## AC-019: Prerequisite Gate

### AC-019-01: Gate shows each prerequisite's completion status
```gherkin
Given Lesson 15 requires Lessons 11, 12, 13, 14
And Marcus has completed Lessons 11 and 12 but not 13 and 14
When Marcus opens the Lesson 15 detail card
Then Marcus sees:
  Lesson 11: Completed
  Lesson 12: Completed
  Lesson 13: Not completed
  Lesson 14: Not completed
And Marcus sees: "2 more prerequisites needed — approximately 2 sessions"
```

### AC-019-02: Gate updates after prerequisite completion
```gherkin
Given Marcus completes Lesson 13 during a session
When Marcus navigates to the Lesson 15 detail card
Then Lesson 13 shows as "Completed" in the prerequisite list
And the session estimate updates to reflect the new count
```

---

## AC-020: Session Hard Cap

### AC-020-01: Platform does not start lesson when budget is insufficient
```gherkin
Given Marcus has 2 minutes 10 seconds of session budget remaining
And the next lesson is estimated at 3 minutes
When the queue summary screen appears
Then no "Start Lesson" button or action is available
And Marcus sees a message indicating the session target is nearly reached
And the session is marked complete for streak purposes
```

### AC-020-02: Review queue truncates at budget boundary
```gherkin
Given Marcus has 25 seconds of session budget remaining
And 1 exercise remains in the review queue
When the platform evaluates whether to start the next exercise
Then the exercise is not started
And the exercise is added to the next session's queue (not discarded)
And Marcus sees "Session target reached — 1 exercise deferred to tomorrow"
```

### AC-020-03: Session duration tracking is accurate
```gherkin
Given Marcus starts a session at time T
When Marcus reaches the session summary screen at time T + X
Then the session_duration shown is X seconds (within a 2-second tolerance)
```

### AC-020-04: Hard cap is exactly 900 seconds
```gherkin
Given the platform's session cap configuration
Then the maximum allowed session_duration is 900 seconds (15 minutes exactly)
And any session with duration >= 900 seconds is treated as cap-reached
```

---

## Cross-Cutting Acceptance Criteria

### XC-001: No user-visible technical identifiers
```gherkin
Given any error, warning, or informational message is shown to the user
Then the message does not contain:
  Database error codes (e.g., "PG::UniqueViolation")
  HTTP status codes as primary content (e.g., "Error 500")
  Stack traces or file paths
  Internal user IDs or UUIDs
  SQL query fragments
```

### XC-002: Session timer does not count during lesson load failures
```gherkin
Given a lesson fails to load
When the error message is displayed
Then the session_duration timer is paused
And the timer does not resume until the user explicitly retries
```

### XC-003: SM-2 records are never lost on page refresh
```gherkin
Given Marcus submits an exercise answer
When Marcus refreshes the page immediately after submission
Then the SM-2 review record for that exercise is preserved in the database
And Marcus does not need to re-submit the exercise
```

### XC-004: Keyboard shortcuts are documented in UI (discoverable)
```gherkin
Given Marcus is on any primary application screen (session, exercise, dashboard, curriculum)
When Marcus reads the visible UI without opening any help section
Then Marcus can see the keyboard shortcuts available on that screen
```

### XC-005: All pages render without console errors in browser
```gherkin
Given any application page loads successfully
When the browser's developer console is inspected
Then no JavaScript errors are logged at error level
And no uncaught exceptions are present
```
