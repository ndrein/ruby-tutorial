# Milestone 4: SM-2 Spaced Repetition Engine (US-05)
#
# Covers: AC-05-01 through AC-05-09
# Driving ports: ExercisesController (→ ReviewScheduler → SM2Algorithm)
#                SessionsController (→ SessionPlanner → ReviewQueue)
#
# SM-2 is correctness-critical. Full coverage of algorithm invariants required.
# All scenarios @skip until milestone-2 daily session scenarios pass.

Feature: SM-2 spaced repetition engine schedules reviews based on answer quality
  As an experienced developer building long-term retention of Ruby syntax
  I want reviews to be scheduled by the SM-2 algorithm based on my performance
  So that my limited practice time is spent on what I am most likely to forget

  # ---- Correct Answer (AC-05-01, BR-07) ----

  @skip
  Scenario: Correct answer increases the review interval by the ease factor
    Given an exercise with a current review interval of 2 days and ease factor of 2.5
    When Ana submits a correct answer
    Then the new review interval is 5 days (2 multiplied by 2.5)
    And the ease factor remains 2.5
    And the next review date is 5 days from today

  @skip
  Scenario: Correct answer on an interval of 1 day produces the minimum valid interval
    Given an exercise with a current review interval of 1 day and ease factor of 2.5
    When Ana submits a correct answer
    Then the new review interval is at least 1 day
    And the next review date is 1 or more days from today

  # ---- Incorrect Answer (AC-05-02, BR-08) ----

  @skip
  Scenario: Incorrect answer resets the review interval to 1 day and reduces ease factor
    Given an exercise with a current review interval of 6 days and ease factor of 2.5
    When Ana submits an incorrect answer
    Then the new review interval is 1 day
    And the ease factor decreases to 2.3 (reduced by 0.2)
    And the next review date is tomorrow

  @skip
  Scenario: Ease factor minimum of 1.3 is enforced and never goes lower
    Given an exercise with ease factor 1.4
    When Ana submits an incorrect answer
    Then the ease factor decreases to 1.3 (reduced by 0.1 to reach the minimum)
    And submitting another incorrect answer does not reduce the ease factor below 1.3

  @skip
  Scenario Outline: Ease factor minimum is enforced across multiple consecutive incorrect answers
    Given an exercise with ease factor <starting_ef>
    When Ana submits <incorrect_count> incorrect answers in sequence
    Then the ease factor is <final_ef> and not lower

    Examples:
      | starting_ef | incorrect_count | final_ef |
      | 2.5         | 1               | 2.3      |
      | 2.5         | 6               | 1.3      |
      | 1.4         | 1               | 1.3      |
      | 1.3         | 3               | 1.3      |

  # ---- Skipped Exercises (AC-05-07, BR-09) ----

  @skip
  Scenario: Skipped exercise is re-queued for the next session with ease factor unchanged
    Given an exercise with ease factor 2.5 and review interval of 4 days
    When Ana presses Esc to skip the exercise
    Then the ease factor remains 2.5
    And the review interval remains 4 days
    And the exercise appears in tomorrow's review queue

  # ---- Missed Exercises (AC-05-08, BR-05) ----

  @skip
  Scenario: Timer expiry (missed) is treated the same as an incorrect answer for SM-2
    Given an exercise with a current review interval of 4 days and ease factor of 2.5
    When the 30-second timer expires without a submission
    Then the new review interval is 1 day
    And the ease factor decreases by 0.2
    And the result type recorded is "missed"

  # ---- Daily Queue Computation (AC-05-04, BR-03) ----

  @skip
  Scenario: Daily review queue contains exactly the exercises due today, ordered most-overdue first
    Given 8 exercises have a due date on or before today
    And 4 exercises have a due date after today
    When the session dashboard computes today's review queue
    Then the queue contains exactly 8 exercises
    And the most overdue exercise is listed first
    And the 4 future exercises are not in today's queue

  @skip
  Scenario: Exercises due exactly today are included in the review queue
    Given an exercise has a due date matching today's date exactly
    When the session dashboard computes today's review queue
    Then that exercise is included in today's queue

  @skip
  Scenario: Exercises due tomorrow are not included in today's review queue
    Given an exercise has a due date of tomorrow
    When the session dashboard computes today's review queue
    Then that exercise is not included in today's queue

  # ---- Daily Cap and Deferral (AC-05-05, BR-04) ----

  @skip
  Scenario: Daily cap of 12 exercises is enforced and excess deferred to next session
    Given 18 exercises are due today
    When the session starts
    Then today's review queue contains exactly 12 exercises
    And the 6 deferred exercises have their next due date unchanged
    And tomorrow's queue includes those 6 deferred exercises with high priority

  @skip
  Scenario: Daily cap counts exercises, not lessons
    Given 15 exercises are due today from 5 different lessons (3 exercises each)
    When the session starts
    Then today's review queue contains 12 exercises regardless of which lessons they come from

  # ---- State Durability (AC-05-06) ----

  @skip
  Scenario: SM-2 state survives a browser refresh before the session is complete
    Given Ana has completed 3 review exercises with updated intervals
    And the session has not yet been marked complete
    When the browser tab is refreshed
    Then the 3 completed exercises show their updated review intervals
    And the remaining review queue is unchanged
    And Ana can resume the session from where she left off

  @skip
  Scenario: SM-2 state is persisted per exercise, not only at session end
    Given Ana completes a review exercise with a correct answer
    And the session is still in progress
    Then the review interval for that exercise is already saved to storage
    And this state would survive an unexpected session interruption

  # ---- SM-2 Initialization (AC-01-13, US-05 domain) ----

  @skip
  Scenario: SM-2 initializes with default values on the first exercise of a new lesson
    Given an exercise that has never been reviewed
    When Ana completes it for the first time
    Then its initial ease factor is set to 2.5
    And its initial review interval is set to 1 day
    And its next review date is tomorrow

  # ---- Storage Reset (AC-05-09) ----

  @skip
  Scenario: Platform launches in first-time mode when all storage is cleared
    Given all stored progress data has been cleared
    When Ana opens the platform
    Then she sees the message "No previous progress found. Starting fresh."
    And the first-time onboarding flow begins from the welcome screen
