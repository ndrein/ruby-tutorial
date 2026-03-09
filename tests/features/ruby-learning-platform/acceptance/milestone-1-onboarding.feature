# Milestone 1: First-Time Onboarding (US-01)
#
# Covers: AC-01-01 through AC-01-15
# Driving ports: OnboardingController (→ CurriculumMap, SessionPlanner)
#                ExercisesController (→ AnswerEvaluator, ReviewScheduler)
#
# Implementation sequence: enable one scenario at a time.
# The first scenario below (@wip) is the starting point for DELIVER wave.
# All others are @skip until the prior one passes.

Feature: First-time onboarding for an experienced developer
  As an experienced Python/Java developer opening a new learning tool
  I want the platform to immediately signal that it respects my expertise
  So that I commit to daily practice rather than abandoning it as too beginner

  Background:
    Given Ana opens the Ruby Learning Platform for the first time
    And no prior progress exists in the system

  # ---- Expert Calibration (AC-01-01, AC-01-02) ----

  @wip
  Scenario: Welcome screen shows assumed expert knowledge before any other content
    When the platform launches
    Then she sees the heading "Ruby for Experienced Developers"
    And she sees "OOP (classes, inheritance)" in the assumed knowledge list
    And she sees "Control flow (if/else, loops, exceptions)" in the assumed knowledge list
    And she sees an explanation that the tool teaches Ruby-specific differences only
    And there is no login form on the screen
    And there is no account creation prompt on the screen

  @skip
  Scenario: Pressing Enter on the welcome screen goes directly to the curriculum tree
    Given Ana is on the welcome screen
    When she presses Enter
    Then the curriculum tree loads immediately
    And she has not passed through any intermediate screen or wizard step

  # ---- Curriculum Tree Initial State (AC-01-03, AC-01-04, AC-01-05) ----

  @skip
  Scenario: Curriculum tree shows only Lesson 1 as available on first launch
    Given Ana has pressed Enter on the welcome screen
    When the curriculum tree loads
    Then Lesson 1 "Syntax Differences" shows as available
    And Lessons 2 through 25 each show as locked
    And each locked lesson shows the label of its prerequisite lesson

  @skip
  Scenario: Selecting a locked lesson shows an educational lock screen, not an error
    Given the curriculum tree is visible
    And Lesson 2 is locked because Lesson 1 is not yet complete
    When Ana navigates to Lesson 2 and presses Enter
    Then a lock screen appears showing "Requires: Lesson 1 (not yet complete)"
    And the lock screen shows the topics that Lesson 2 covers
    And the lock screen shows the topics that Lesson 1 covers as the prerequisite
    And pressing Esc returns her to the curriculum tree

  # ---- Lesson Preview (AC-01-07) ----

  @skip
  Scenario: Lesson preview shows both covered topics and what is explicitly not covered
    Given Ana is on the curriculum tree
    When she navigates to Lesson 1 and presses Enter
    Then a lesson preview screen loads before any exercises begin
    And she sees the list of topics Lesson 1 covers
    And she sees a "What this does NOT cover" section listing at least one foundational concept
    And she sees an estimated duration and the number of exercises
    And no exercise has started yet

  # ---- Exercise Timer (AC-01-08, AC-01-09, AC-01-10) ----

  @skip
  Scenario: Exercise timer starts automatically when an exercise loads
    Given Ana has started Lesson 1 from the preview screen
    When the first exercise loads
    Then a 30-second countdown timer is visible on screen
    And the timer is counting down without any user interaction
    And the answer input field has keyboard focus

  @skip
  Scenario: Timer expiry shows the correct answer automatically and records a missed result
    Given Ana is on Exercise 1 of Lesson 1
    And she has not submitted any answer
    When 30 seconds pass without a submission
    Then the correct answer appears on screen automatically
    And the feedback shows "Time." before displaying the answer
    And her result is recorded as "missed" in the review schedule
    And the next exercise loads after a brief pause

  @skip
  Scenario: Pressing Esc on an exercise skips it without penalty and re-queues it
    Given Ana is on Exercise 1 of Lesson 1
    When she presses Esc to skip the exercise
    Then the correct answer is shown
    And her result is recorded as "skipped" not "failed"
    And the exercise is added to tomorrow's review queue
    And her review interval for this exercise is unchanged

  # ---- Exercise Feedback (AC-01-11, AC-01-12) ----

  @skip
  Scenario: Correct answer shows a Ruby-specific explanation without gamification
    Given Ana submits a correct answer to Exercise 1 of Lesson 1
    When the feedback screen loads
    Then the first word displayed is "Correct."
    And the canonical Ruby answer is shown with code formatting
    And the explanation describes what is specifically different in Ruby compared to Python or Java
    And no score, points, XP, badges, or achievement language appears on screen

  @skip
  Scenario: Incorrect answer shows the correct answer with factual explanation, no shame language
    Given Ana submits an incorrect answer to Exercise 1 of Lesson 1
    When the feedback screen loads
    Then the correct answer is shown with code formatting
    And the explanation is factual and describes the Ruby difference
    And no apologetic, critical, or shame-inducing language appears
    And the result is recorded as incorrect in the review schedule

  # ---- First Session Summary (AC-01-13) ----

  @skip
  Scenario: First session summary shows SM-2 initialization and the next lesson title
    Given Ana has completed all exercises in Lesson 1
    When the session complete screen renders
    Then she sees the number of exercises completed
    And she sees a brief explanation that the system will schedule future reviews automatically
    And she sees the title of the next lesson available
    And she sees an estimated review count for the next session
    And all review schedule data from Lesson 1 has been saved

  @skip
  Scenario: Ana can continue to the next lesson immediately from the session summary
    Given Ana is on the session summary screen after completing Lesson 1
    When she presses "n"
    Then Lesson 2 loads immediately
    And all review data from Lesson 1 is already saved before Lesson 2 starts

  # ---- Keyboard Navigation (AC-01-14) ----

  @skip
  Scenario: All actions on the welcome screen are reachable without a mouse
    Given the welcome screen is visible
    Then every interactive element is reachable via keyboard alone
    And no action requires a mouse click
    And all focused elements show a visible focus indicator

  @skip
  Scenario: All actions on the curriculum tree are reachable without a mouse
    Given the curriculum tree is visible
    When Ana presses "j" three times
    Then the cursor moves to Lesson 4
    When Ana presses "k" once
    Then the cursor moves back to Lesson 3
    When Ana presses Enter
    Then the selected lesson opens

  # ---- Session Persistence (AC-01-15) ----

  @skip
  Scenario: Pressing Esc mid-lesson saves position so Ana can resume tomorrow
    Given Ana has completed 2 of 3 exercises in Lesson 1
    When she presses Esc to return to the curriculum tree
    Then her position in Lesson 1 is saved
    And the next time she opens Lesson 1 it resumes from Exercise 3, not Exercise 1
    And the review data from her 2 completed exercises is preserved

  # ---- Error and Edge Cases ----

  @skip
  Scenario: Platform starts in first-time mode when no prior session data exists
    Given the platform has no stored progress data
    When Ana opens the platform
    Then she sees "No previous progress found. Starting fresh." before the welcome screen
    And the onboarding flow begins from the welcome screen

  @skip
  Scenario: Keyboard shortcut overlay is accessible from any onboarding screen
    Given Ana is on the welcome screen
    When she presses "?"
    Then a keyboard shortcut reference overlay appears listing all shortcuts
    When she presses Esc
    Then the overlay closes and the welcome screen is visible again

  # ---- Property Scenarios (tagged for property-based test implementation) ----

  @property @skip
  Scenario: Every onboarding screen element is reachable by keyboard only
    Given any onboarding screen is visible
    Then all interactive elements are reachable via Tab, j/k, or Enter
    And no action requires a mouse click
    And focus indicators are visible on all focused elements

  @property @skip
  Scenario: No session or exercise data is lost on navigation
    Given Ana is mid-lesson and presses Esc to return to the curriculum tree
    Then her progress in the current lesson is saved
    And returning to the lesson resumes from the last completed exercise
    And no review data from already-completed exercises is lost
