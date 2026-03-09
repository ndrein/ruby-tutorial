# Milestone 5: Exercise Timer (US-04)
#
# Covers: AC-04-01 through AC-04-04
# Driving ports: ExercisesController (→ AnswerEvaluator)
#                Timer behavior validated through the exercise presentation surface
#
# All scenarios @skip until milestone-1 onboarding scenarios pass.

Feature: 30-second exercise timer enforces recall discipline
  As an experienced developer practicing Ruby recall
  I want each exercise to have a strict 30-second timer
  So that I develop quick recall rather than extended reasoning

  # ---- Timer Start (AC-04-01, AC-04-02) ----

  @skip
  Scenario: Timer starts automatically when an exercise loads, before any user input
    Given Ana has started a lesson or review session
    When an exercise loads on screen
    Then a visible countdown timer appears immediately
    And the timer is already counting down without any keypress required
    And the answer input field has keyboard focus

  @skip
  Scenario: Timer is visible as a progress bar with the seconds remaining shown
    Given an exercise is on screen
    When Ana looks at the exercise view
    Then she sees a visual progress bar representing time remaining
    And she sees the number of seconds remaining

  # ---- Timer Expiry (AC-04-03) ----

  @skip
  Scenario: Timer expiry at 0 seconds shows the correct answer automatically
    Given Ana is on an exercise with the timer running
    And she has not submitted any answer
    When the 30-second timer reaches 0
    Then the correct answer appears on screen without any user action
    And the label "Time." appears before the answer
    And her result for this exercise is recorded as "missed"

  @skip
  Scenario: After timer expiry the next exercise loads automatically after a brief pause
    Given the timer has expired and the correct answer is shown
    When 3 seconds pass
    Then the next exercise in the sequence loads automatically

  # ---- Hint (AC-04-04) ----

  @skip
  Scenario: Pressing Tab shows a partial hint without revealing the full answer
    Given Ana is on an exercise with the timer running
    When she presses Tab
    Then a partial hint appears on screen
    And the hint does not reveal the complete correct answer
    And the timer continues counting down

  @skip
  Scenario: Tab hint is available exactly once per exercise
    Given Ana is on an exercise and she has already pressed Tab to reveal the hint
    When she presses Tab a second time
    Then no additional hint appears
    And the hint slot for this exercise is consumed

  @skip
  Scenario: Hint does not stop the timer
    Given Ana is on an exercise
    When she presses Tab to show the hint at the 20-second mark
    Then the timer continues from 20 seconds downward
    And the timer still reaches 0 if she does not submit before it expires

  # ---- Timer Coexists with Answer Submission ----

  @skip
  Scenario: Submitting an answer before the timer expires stops the timer
    Given Ana is on an exercise with the timer running at 15 seconds remaining
    When she types her answer and presses Enter to submit
    Then the timer stops
    And the feedback screen shows her answer result
    And the timer does not expire after her submission

  # ---- Error and Edge Cases ----

  @skip
  Scenario: Each new exercise gets a fresh 30-second timer
    Given Ana has completed one exercise with 10 seconds remaining on the timer
    When the next exercise loads
    Then the timer resets to 30 seconds for the new exercise
    And the previous exercise's remaining time does not carry over

  @skip
  Scenario: Timer state does not persist if Ana navigates away and returns to the exercise
    Given Ana is mid-exercise with 15 seconds remaining
    When she presses Esc and then returns to resume the lesson
    Then the exercise resumes with a fresh 30-second timer
    And no timer state from the previous viewing is carried over
