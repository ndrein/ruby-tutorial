Feature: Daily Session
  As an experienced developer building a daily Ruby practice habit
  I want my session to be pre-organized by the system each day
  So that I spend all session time learning, not deciding what to learn

  Background:
    Given Ana Folau has been practicing for 14 days
    And she has completed Lessons 1-4
    And SM-2 has 6 exercises due today from Lessons 1-4
    And the next available lesson is Lesson 5 "Array Methods"

  # ---- Session Start ----

  Scenario: Session dashboard pre-computes today's full plan
    When Ana opens the platform
    Then the session dashboard shows the review queue size (6 exercises)
    And it shows an estimated review time (~3 min)
    And it shows the next lesson title and estimated duration (~4 min)
    And it shows a total session time estimate (~7 min)
    And no selection is required to begin

  Scenario: Session dashboard handles empty review queue gracefully
    Given SM-2 has 0 exercises due today
    When Ana opens the platform
    Then the session dashboard shows "Review queue: 0 exercises (all caught up)"
    And it shows only the new lesson as today's plan
    And pressing Enter goes directly to the lesson

  Scenario: Oversized review queue is capped and remainder deferred
    Given SM-2 has 18 exercises due today (Ana missed 3 days)
    When Ana opens the platform
    Then the session dashboard shows "18 due. Today's session will cover 12; 6 carry to tomorrow"
    And the session includes exactly 12 review exercises
    And the 6 deferred exercises appear first in tomorrow's queue

  # ---- Review Queue ----

  Scenario: Review exercises presented in SM-2 urgency order
    Given Ana starts the session
    When the review queue begins
    Then the most overdue exercise is presented first
    And each exercise shows its source lesson name
    And the 30-second timer starts automatically on each exercise

  Scenario: Correct review answer extends SM-2 interval
    Given Ana submits a correct answer on a review exercise for Lesson 2
    And the exercise's current SM-2 interval was 2 days
    When the feedback screen loads
    Then the next review interval shown is greater than 2 days
    And the word "Correct." appears first

  Scenario: Incorrect review answer resets SM-2 to 1-day interval
    Given Ana submits an incorrect answer on a review exercise
    When the feedback screen loads
    Then the correct answer is shown with explanation
    And the next review interval is 1 day
    And SM-2 records the regression in ease factor

  Scenario: Skipped review exercise defers to next session
    Given Ana presses Esc on a review exercise
    When the feedback screen loads
    Then the correct answer is shown
    And the exercise is marked as "skipped" (not failed)
    And it appears in tomorrow's review queue as high-priority

  # ---- Review to Lesson Transition ----

  Scenario: Review complete screen shows accurate performance summary
    Given Ana has completed all 6 review exercises
    And 5 were correct and 1 was incorrect
    When the review complete screen renders
    Then she sees "5/6 (83%)" accuracy
    And she sees an estimated count for tomorrow's review queue
    And pressing Enter advances to the new lesson

  # ---- New Lesson ----

  Scenario: New lesson uses Python/Java comparison format
    Given Ana has completed the review queue
    When Lesson 5 content loads
    Then the lesson shows a Python equivalent before the Ruby form
    And there is no explanation of what a list, loop, or iteration is
    And the lesson focuses on Ruby-specific syntax differences
    And the content fits within the remaining session time budget

  # ---- Session Complete ----

  Scenario: Session summary shows accurate totals and next session plan
    Given Ana has completed 6 reviews and 3 lesson exercises
    When the session complete screen renders
    Then she sees total exercises completed (9)
    And she sees the session duration
    And she sees her current streak (14 days)
    And she sees the next lesson title for tomorrow
    And she sees tomorrow's estimated review count

  Scenario: Session persists SM-2 state before exit
    Given Ana has completed her session
    When she presses Enter to exit
    Then all SM-2 intervals are persisted to storage
    And the streak counter increments from 14 to 15
    And tomorrow's session dashboard will show the updated review queue

  Scenario: User can start next lesson immediately from summary
    Given Ana is on the session complete screen
    When she presses "n"
    Then Lesson 6 starts immediately
    And SM-2 data from today's session is already saved

  # ---- Time Budget ----

  Scenario: Session does not cut off mid-exercise at time limit
    Given Ana's session has reached the 15-minute mark
    And she is mid-exercise
    When the time limit is reached
    Then the current exercise completes normally
    And the session summary shows which exercises were deferred
    And deferred exercises appear at the top of tomorrow's queue

  # ---- Topic Override ----

  Scenario: User can override SM-2-recommended lesson with topic selection
    Given Ana is on the session dashboard
    When she presses "t"
    Then the topic selection view opens
    And she can select a different lesson (if available)
    And the review queue is preserved unchanged
    And the session proceeds with the selected lesson instead of the recommended one

  # ---- Property Scenarios ----

  @property
  Scenario: SM-2 scheduling is consistent across sessions
    Given Ana completes an exercise correctly multiple sessions in a row
    Then the next review interval increases each time (not random)
    And intervals follow the SM-2 algorithm (each interval = previous * ease_factor)

  @property
  Scenario: Session total time respects 15-minute cap
    Given a review queue of any size up to the daily cap
    And a standard new lesson with 3 exercises
    Then the session completes within 15 minutes
    And the system enforces the cap by deferring exercises, not by truncating mid-exercise
