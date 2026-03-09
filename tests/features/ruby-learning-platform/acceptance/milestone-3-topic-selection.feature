# Milestone 3: Topic Selection and Lesson Tree Navigation (US-03, US-08)
#
# Covers: AC-03-01 through AC-03-11, AC-08-01 through AC-08-06
# Driving ports: LessonsController (→ CurriculumMap, LessonUnlocker, LockScreenPolicy)
#
# All scenarios @skip until walking-skeleton scenario 3 passes.

Feature: Curriculum tree navigation lets Ana find and unlock the topic she needs
  As an experienced developer with an immediate work need for a Ruby concept
  I want to navigate the curriculum tree and understand what stands in my way
  So that I can reach the topic I need without bypassing important prerequisites

  Background:
    Given Ana has been practicing for 21 days
    And she has completed Module 1 (Lessons 1 through 5)
    And she has not yet started Module 2
    And Lesson 6 is the only available lesson in Module 2

  # ---- Curriculum Tree Access (AC-03-01) ----

  @skip
  Scenario: Curriculum tree is accessible via "t" from the session dashboard
    Given Ana is on the session dashboard
    When she presses "t"
    Then the curriculum tree opens
    And the session dashboard state is preserved when she returns

  @skip
  Scenario: Curriculum tree is accessible via "c" from any screen
    Given Ana is on any screen in the application
    When she presses "c"
    Then the curriculum tree opens
    And pressing Esc returns her to the screen she came from

  # ---- Curriculum Tree Display (AC-03-02, AC-03-03, AC-08-01) ----

  @skip
  Scenario: Curriculum tree shows accurate lock and completion states for all 25 lessons
    When Ana opens the curriculum tree
    Then Module 1 shows status "COMPLETE"
    And Module 2 shows status "IN PROGRESS"
    And Lesson 6 shows as available with no lock indicator
    And Lessons 7 through 10 show as locked with their respective prerequisite labels
    And Modules 3 through 5 show as "LOCKED"
    And all 25 lessons are shown

  @skip
  Scenario: Curriculum tree renders within the performance target
    When Ana opens the curriculum tree
    Then all 25 lessons are visible and interactive within 300 milliseconds

  # ---- Keyboard Navigation in Tree (AC-03-01, AC-07-01, AC-07-02) ----

  @skip
  Scenario: j and k move the cursor one lesson at a time through the tree
    Given Ana is in the curriculum tree
    When she presses "j" to move down
    Then the cursor moves to the next lesson in the list
    When she presses "k" to move up
    Then the cursor moves to the previous lesson

  @skip
  Scenario: J and K jump between module boundaries
    Given Ana is in the curriculum tree with the cursor on Lesson 3
    When she presses "J" (shift-j)
    Then the cursor jumps to the first lesson of the next module
    When she presses "K" (shift-k)
    Then the cursor jumps to the first lesson of the previous module

  # ---- Keyword Search (AC-03-08, AC-07-09) ----

  @skip
  Scenario: Pressing "/" opens inline keyword search that filters the tree
    Given Ana is in the curriculum tree
    When she presses "/" and types "block"
    Then the tree filters to show only lessons matching "block" in title or topics
    And Lesson 7 "Blocks and Yield" is visible in the filtered results
    And lessons that do not match "block" are hidden from view
    When she presses Esc
    Then the full curriculum tree restores with no filter active

  @skip
  Scenario: Search with no matching lessons shows an empty state message
    Given Ana is in the curriculum tree
    When she presses "/" and types "xyznotalesson"
    Then the tree shows a message indicating no lessons match the search
    And pressing Esc restores the full curriculum tree

  # ---- Lock Screen (AC-03-04, AC-03-05, AC-03-06) ----

  @skip
  Scenario: Selecting a locked lesson shows a lock screen with educational content
    Given Ana navigates to Lesson 7 which requires Lesson 6 to be complete
    When she presses Enter
    Then a lock screen appears (not an error message)
    And the lock screen shows "Requires: Lesson 6 (not yet complete)"
    And the lock screen shows the topics that Lesson 7 covers
    And the lock screen shows the topics that Lesson 6 covers
    And pressing Enter navigates her to Lesson 6

  @skip
  Scenario: Lock screen with multiple prerequisites shows which are complete and which are not
    Given Lesson 10 requires both Lesson 8 and Lesson 9
    And Lesson 8 is complete but Lesson 9 is not
    When Ana selects Lesson 10
    Then the lock screen shows Lesson 8 as "complete"
    And the lock screen shows Lesson 9 as "not yet complete"
    And pressing Enter navigates to Lesson 9, the incomplete prerequisite

  @skip
  Scenario: Selecting an available lesson goes directly to the lesson without a lock screen
    Given Lesson 6 is currently available
    When Ana navigates to Lesson 6 and presses Enter
    Then the lesson preview screen loads directly
    And no lock screen appears

  # ---- No Force-Skip (AC-03-07) ----

  @skip
  Scenario: There is no way to bypass a prerequisite gate in any part of the UI
    Given Ana is on a lock screen for any locked lesson
    Then there is no "skip prerequisite" option visible
    And there is no "unlock anyway" option visible
    And the only available actions are Enter to go to the prerequisite and Esc to go back

  # ---- Prerequisite Unlock (AC-03-09, AC-03-10, AC-08-02, AC-08-03) ----

  @skip
  Scenario: Completing a prerequisite lesson unlocks the target lesson before the summary renders
    Given Ana has completed all exercises in Lesson 6
    When the Lesson 6 complete screen renders
    Then Lesson 7 is shown as newly unlocked on the completion screen
    And the curriculum tree (if opened) shows Lesson 7 as available
    And there is no intermediate state where Lesson 7 shows as ambiguous or still locked

  @skip
  Scenario: Completing the last lesson in a module updates the module status to COMPLETE
    Given Ana has completed Lessons 1 through 4
    When she completes Lesson 5
    Then Module 1 shows status "COMPLETE"
    And Module 2 shows status "IN PROGRESS"
    And Lesson 6 changes from locked to available at the same moment

  @skip
  Scenario: Unlock state persists after Ana saves her progress and returns the next day
    Given Ana has unlocked Lesson 7 by completing Lesson 6
    And she pressed Esc to save for the next session
    When she opens the platform the following day
    Then Lesson 7 is still shown as available, not locked
    And the session dashboard recommends Lesson 7 as the next lesson

  # ---- SM-2 from Topic-Selection Path (AC-03-11) ----

  @skip
  Scenario: Exercises completed via topic selection are recorded with the same SM-2 weight as daily sessions
    Given Ana completes Lesson 6 exercises by navigating through the curriculum tree
    When she answers an exercise correctly
    Then the review schedule is updated using the same SM-2 algorithm as a daily session exercise
    And Lesson 6 exercises appear in future review queues at the normal SM-2 interval

  # ---- Unlock Notification and Next Step (US-08 scenario) ----

  @skip
  Scenario: After unlocking, Ana can start the newly available lesson immediately
    Given Ana has just completed Lesson 6 and Lesson 7 is now unlocked
    When the completion screen renders
    Then she sees Lesson 7 listed as newly unlocked
    And pressing Enter starts Lesson 7 immediately
    And pressing Esc instead saves Lesson 7 as the next recommended session

  # ---- Session Integration (US-03 session scenario) ----

  @skip
  Scenario: Selecting a lesson via "t" override preserves the SM-2 review queue
    Given Ana is on the session dashboard with 4 review exercises due
    When she presses "t" and selects an available lesson different from the recommended one
    And she begins the session
    Then the 4 review exercises run first, unchanged from the original plan
    And the manually selected lesson runs after the review queue

  # ---- Error and Edge Cases ----

  @skip
  Scenario: Lesson 1 is always shown as available on the very first launch
    Given the platform has no prior progress data
    When Ana opens the curriculum tree
    Then Lesson 1 shows as available
    And all other lessons show as locked

  @skip
  Scenario: Session summary shows lessons from both prerequisite and target when completed in one sitting
    Given Ana completes both Lesson 6 and Lesson 7 in the same sitting
    When the session complete screen renders
    Then it shows both Lesson 6 and Lesson 7 as completed today
    And review schedule entries exist for exercises from both lessons

  # ---- Property Scenarios ----

  @property @skip
  Scenario: Lock state is consistent across all views in the same session
    Given a lesson's completion status changes because Ana just completed it
    Then within the same session all views show the updated status
    And the curriculum tree shows the correct availability icon
    And the session dashboard next-lesson recommendation reflects the change
    And the lock screen for any dependent lesson shows the correct prerequisite completion
    And the progress dashboard shows the updated lesson count

  @property @skip
  Scenario: The prerequisite graph is acyclic and all references point to earlier lessons
    Given the full curriculum prerequisite graph is loaded
    Then no lesson is listed as a prerequisite of itself
    And all prerequisite references point to lower-numbered lessons
    And completing lessons in sequential order satisfies all prerequisites
