# Milestone 2: Daily Session Flow (US-02)
#
# Covers: AC-02-01 through AC-02-13
# Driving ports: SessionsController (→ SessionPlanner, SessionState)
#                ExercisesController (→ AnswerEvaluator, ReviewScheduler)
#
# All scenarios @skip until walking-skeleton scenario 2 passes.

Feature: Daily session flow delivers pre-planned practice without decisions
  As an experienced developer with a hard 15-minute morning practice window
  I want the platform to have already planned today's session when I arrive
  So that I spend all session time learning, not deciding what to learn

  Background:
    Given Ana has been practicing for 14 days
    And she has completed Lessons 1 through 4
    And the next available lesson is Lesson 5 "Array Methods"

  # ---- Session Dashboard (AC-02-01, AC-02-02) ----

  @skip
  Scenario: Session dashboard shows the complete pre-computed plan on opening
    Given 6 review exercises are due today from Lessons 1 through 4
    When Ana opens the platform
    Then the session dashboard shows a review count of 6 exercises
    And it shows an estimated time for the review queue
    And it shows the next lesson title "Array Methods" with an estimated duration
    And it shows a total session time estimate
    And no selection is required before pressing Enter to begin

  @skip
  Scenario: Session dashboard renders within the performance target
    Given any valid session state exists
    When Ana opens the platform
    Then the session dashboard is fully rendered and ready within 500 milliseconds

  # ---- Empty Queue (AC-02-03) ----

  @skip
  Scenario: Dashboard shows "all caught up" message when no reviews are due
    Given 0 review exercises are due today
    When Ana opens the platform
    Then the session dashboard shows "Review queue: 0 exercises (all caught up)"
    And it shows only the new lesson as today's plan
    And pressing Enter goes directly to the lesson without a review phase

  # ---- Review Cap and Deferral (AC-02-04) ----

  @skip
  Scenario: Oversized review queue is capped at 12 with remainder deferred to tomorrow
    Given 18 review exercises are due today because Ana missed 3 days
    When Ana opens the platform
    Then the session dashboard shows that 18 exercises are due
    And it shows that today's session will cover 12 and 6 will carry to tomorrow
    And the session includes exactly 12 review exercises
    And the 6 deferred exercises are not part of today's session

  @skip
  Scenario: Deferred exercises appear first in tomorrow's review queue
    Given 18 review exercises are due today
    And Ana completes today's session with 12 reviews
    When she opens the platform the next day
    Then the 6 previously deferred exercises appear at the top of the review queue
    And they are shown before any newly due exercises

  # ---- Review Queue Order (AC-02-05) ----

  @skip
  Scenario: Review exercises are presented most-overdue first
    Given Ana starts the review phase of her session
    When the review queue begins
    Then the exercise with the oldest due date is presented first
    And each exercise shows the name of the lesson it came from
    And the 30-second timer starts automatically for each exercise

  # ---- SM-2 Interaction During Review (AC-02-06, AC-02-07) ----

  @skip
  Scenario: Correct review answer extends the SM-2 interval beyond the current value
    Given a review exercise from Lesson 2 with a current review interval of 2 days
    When Ana submits a correct answer
    Then the feedback screen shows the next review interval is greater than 2 days
    And the feedback begins with the word "Correct."

  @skip
  Scenario: Incorrect review answer resets the SM-2 interval to 1 day
    Given a review exercise from Lesson 2 with any current review interval
    When Ana submits an incorrect answer
    Then the correct answer is shown with an explanation
    And the next review interval for this exercise is 1 day
    And the ease factor for this exercise decreases

  @skip
  Scenario: Skipped review exercise defers to tomorrow without penalty to ease factor
    Given Ana is on a review exercise
    When she presses Esc to skip it
    Then the correct answer is shown
    And the exercise is marked as "skipped" not "failed"
    And it appears in tomorrow's review queue as high-priority
    And the ease factor for this exercise is unchanged

  # ---- Review-to-Lesson Transition (AC-02-08) ----

  @skip
  Scenario: Review complete screen shows accuracy and transitions to the new lesson
    Given Ana has completed all 6 review exercises with 5 correct and 1 incorrect
    When the review complete screen renders
    Then she sees her accuracy as "5/6 (83%)"
    And she sees an estimated count for tomorrow's review queue
    And pressing Enter advances her to Lesson 5

  # ---- New Lesson Content (AC-02-09) ----

  @skip
  Scenario: New lesson content shows Python or Java equivalent before Ruby syntax
    Given Ana has completed the review queue
    When Lesson 5 "Array Methods" loads
    Then the lesson shows a Python or Java equivalent before the Ruby form
    And there is no explanation of what a list, loop, or iteration concept is
    And the lesson focuses exclusively on what is different in Ruby
    And the lesson content fits within the remaining session time budget

  # ---- Session Summary (AC-02-10, AC-02-11) ----

  @skip
  Scenario: Session summary shows accurate totals and the next session plan
    Given Ana has completed 6 review exercises and 3 lesson exercises
    When the session complete screen renders
    Then she sees a total of 9 exercises completed
    And she sees the total session duration
    And she sees her current streak as "14 days" in plain text
    And she sees the title of the next lesson for tomorrow
    And she sees tomorrow's estimated review count

  @skip
  Scenario: All SM-2 state is persisted when Ana exits the session
    Given Ana has completed her session
    When she presses Enter to exit
    Then all review intervals are saved to storage
    And the streak counter shows 15 days the following day
    And tomorrow's session dashboard reflects the updated review schedule

  # ---- Continue to Next Lesson (AC-02-13 partial) ----

  @skip
  Scenario: Ana can start the next lesson immediately from the session summary
    Given Ana is on the session complete screen after finishing today's session
    When she presses "n"
    Then the next lesson starts immediately
    And all review data from today's session is already saved

  # ---- Topic Override (AC-02-13) ----

  @skip
  Scenario: Pressing "t" from the session dashboard opens topic selection without losing the plan
    Given Ana is on the session dashboard
    When she presses "t"
    Then the topic selection view opens
    And she can select a different available lesson
    And the review queue is unchanged when she returns to the session
    And the session proceeds with the lesson she selected instead of the recommended one

  # ---- Time Cap (BR-06) ----

  @skip
  Scenario: Session does not cut off mid-exercise when the 15-minute limit is reached
    Given Ana's session has reached the 15-minute mark
    And she is currently answering an exercise
    When the time limit is reached
    Then the current exercise completes without interruption
    And the session summary shows which exercises were deferred
    And the deferred exercises appear at the top of tomorrow's queue

  # ---- Error and Edge Cases ----

  @skip
  Scenario: Session dashboard shows correctly when all review exercises are from a single lesson
    Given all 6 due exercises are from Lesson 1
    When Ana opens the platform
    Then the session dashboard shows all 6 exercises attributed to Lesson 1
    And the plan is otherwise identical to a multi-lesson queue

  @skip
  Scenario: Review queue correctly excludes exercises due in the future
    Given 8 exercises have a due date of today or earlier
    And 4 exercises have a due date tomorrow or later
    When the session dashboard computes today's queue
    Then the queue contains exactly 8 exercises
    And the 4 future exercises are not shown

  @skip
  Scenario: Session persists SM-2 state even if browser tab is refreshed mid-session
    Given Ana has completed 3 review exercises in the current session
    When the browser tab is refreshed before the session ends
    Then the 3 completed exercises retain their updated review intervals
    And the remaining review queue is unchanged
    And Ana can continue the session without losing her place

  # ---- Property Scenarios ----

  @property @skip
  Scenario: SM-2 scheduling is deterministic and consistent across sessions
    Given Ana completes an exercise correctly in multiple consecutive sessions
    Then the next review interval increases each time
    And the interval follows the SM-2 rule: each interval equals the previous interval multiplied by the ease factor

  @property @skip
  Scenario: Session total time never exceeds 15 minutes regardless of queue size
    Given a review queue of any size up to the daily cap of 12 exercises
    And a standard new lesson with 3 exercises
    Then the session completes within 15 minutes
    And the system defers exercises rather than truncating any exercise mid-answer
