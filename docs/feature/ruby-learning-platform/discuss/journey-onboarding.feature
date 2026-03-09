Feature: First-Time Onboarding
  As an experienced developer learning Ruby
  I want a first-run experience that immediately signals expert calibration
  So that I commit to daily practice rather than abandoning the tool as "too beginner"

  Background:
    Given Ana Folau opens the Ruby Learning Platform for the first time
    And no user progress data exists in the system

  # ---- Step 1: Welcome and Calibration ----

  Scenario: Landing screen shows expert calibration messaging immediately
    Given Ana has no prior sessions
    When the platform launches
    Then she sees a heading "Ruby for Experienced Developers"
    And she sees a checklist of assumed knowledge including "OOP (classes, inheritance)"
    And she sees "Control flow (if/else, loops, exceptions)" in the assumed knowledge list
    And she sees an explanation that the tool teaches Ruby-specific differences
    And no login form or account creation is required

  Scenario: No navigation is needed to reach first exercise
    Given Ana is on the welcome screen
    When she presses Enter
    Then the curriculum tree loads immediately
    And no intermediate screens or wizards are shown

  # ---- Step 2: Curriculum Tree ----

  Scenario: Curriculum tree shows Lesson 1 as the only available lesson
    Given Ana has pressed Enter on the welcome screen
    When the curriculum tree loads
    Then Lesson 1 "Syntax Differences" is shown as available (not locked)
    And Lessons 2 through 25 are shown as locked
    And each locked lesson shows its prerequisite lesson reference
    And Module 1 is expanded showing all 5 lesson titles
    And Modules 2-5 are collapsed showing only module names

  Scenario: User can navigate curriculum tree with keyboard
    Given the curriculum tree is visible
    When Ana presses "j" three times
    Then the cursor moves to Lesson 4
    When Ana presses "k" once
    Then the cursor moves back to Lesson 3

  Scenario: Selecting a locked lesson shows a lock screen (not an error)
    Given the curriculum tree is visible
    And Lesson 2 is locked (requires Lesson 1)
    When Ana navigates to Lesson 2 and presses Enter
    Then a lock screen loads showing "Requires: Lesson 1 (not yet complete)"
    And the screen shows what topics Lesson 2 covers
    And the screen shows what topics Lesson 1 covers as prerequisite
    And pressing Esc returns to the curriculum tree

  # ---- Step 3: Lesson Preview ----

  Scenario: Selecting Lesson 1 shows a preview before starting
    Given Ana is on the curriculum tree
    When she navigates to Lesson 1 and presses Enter
    Then a lesson preview screen loads
    And she sees a list of topics covered in Lesson 1
    And she sees a list of topics explicitly NOT covered (variables, OOP, control flow)
    And she sees an estimated duration and exercise count
    And no exercises have started yet

  # ---- Step 4: Exercise Timer ----

  Scenario: Exercise timer starts automatically on render
    Given Ana has started Lesson 1 from the preview screen
    When the first exercise loads
    Then a 30-second countdown timer is visible
    And the timer begins without any user interaction required
    And the answer input field has keyboard focus

  Scenario: Timer expiry shows correct answer automatically
    Given Ana is on Exercise 1 of Lesson 1
    And she has not submitted any answer
    When the 30-second timer expires
    Then the correct answer is displayed automatically
    And her attempt is recorded as "missed" for SM-2 purposes
    And the next exercise loads after a 3-second pause

  Scenario: User can skip an exercise without penalty
    Given Ana is on Exercise 1 of Lesson 1
    When she presses Esc to skip
    Then the correct answer is shown
    And her attempt is recorded as "skipped" (not "failed") for SM-2
    And the exercise is re-queued for the next session

  # ---- Step 5: Exercise Feedback ----

  Scenario: Correct answer shows precise Ruby-specific explanation
    Given Ana has submitted a correct answer to Exercise 1
    When the feedback screen loads
    Then the first word displayed is "Correct."
    And the canonical Ruby answer is shown with code formatting
    And an explanation of the Ruby-specific difference from Python/Java is shown
    And no score, points, XP, or badges are displayed

  Scenario: Incorrect answer shows explanation without shame language
    Given Ana has submitted an incorrect answer to Exercise 1
    When the feedback screen loads
    Then the correct answer is shown
    And the explanation focuses on what is different in Ruby
    And the wording is factual, not apologetic or critical
    And SM-2 records the answer as incorrect for interval calculation

  # ---- Step 6: First Session Summary ----

  Scenario: First session summary initializes SM-2 review schedule
    Given Ana has completed all exercises in Lesson 1
    When the session complete screen renders
    Then she sees the number of exercises completed (3)
    And she sees a brief explanation that SM-2 will schedule reviews
    And she sees the next lesson title (Lesson 2: String Interpolation)
    And she sees an estimated review count for the next session
    And SM-2 state has been persisted to storage

  Scenario: User can continue to Lesson 2 without exiting
    Given Ana has completed Lesson 1 and is on the session summary screen
    When she presses "n"
    Then Lesson 2 starts immediately
    And SM-2 state from Lesson 1 is already saved (not deferred)

  # ---- Property Scenarios ----

  @property
  Scenario: Every interactive element is reachable by keyboard only
    Given any onboarding screen is visible
    Then all interactive elements are reachable via Tab, j/k, or Enter
    And no action requires a mouse click
    And focus indicators are visible on all focused elements

  @property
  Scenario: No session or exercise data is lost on navigation
    Given Ana is mid-lesson and presses Esc to return to curriculum
    Then her progress in the current lesson is saved
    And returning to the lesson resumes from the last completed exercise
    And no SM-2 data from completed exercises is lost
