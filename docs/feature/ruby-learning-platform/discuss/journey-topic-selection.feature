Feature: Topic Selection and Lesson Tree Navigation
  As an experienced developer with specific immediate learning needs
  I want to navigate the curriculum tree and understand prerequisite dependencies
  So that I can reach the topic I need for current work without bypassing important prerequisites

  Background:
    Given Ana Folau has been practicing for 21 days
    And she has completed Module 1 (Lessons 1-5)
    And she has not yet started Module 2
    And Lesson 6 is the only available (unlocked) lesson in Module 2

  # ---- Curriculum Tree ----

  Scenario: Curriculum tree shows accurate lock states for current user
    When Ana opens the curriculum tree
    Then Module 1 shows status [COMPLETE]
    And Module 2 shows status [IN PROGRESS]
    And Lesson 6 shows as available with no lock indicator
    And Lessons 7-10 show as locked with their respective prerequisite labels
    And Modules 3-5 show as [LOCKED] with no lesson details visible

  Scenario: Curriculum tree navigation is fully keyboard-driven
    Given Ana is in the curriculum tree
    When she presses "j" to move down
    Then the cursor moves to the next lesson in order
    When she presses "k" to move up
    Then the cursor moves to the previous lesson
    When she presses "J" (shift-j)
    Then the cursor jumps to the first lesson of the next module
    When she presses "K" (shift-k)
    Then the cursor jumps to the first lesson of the previous module

  Scenario: User can search lessons by keyword
    Given Ana is in the curriculum tree
    When she presses "/" and types "block"
    Then the tree filters to show only lessons matching "block" in title or description
    And Lesson 7 "Blocks and Yield" is visible in the filtered results
    And Lesson 8 "Procs and Lambdas" is visible (contains block-related content)
    And all other lessons are hidden from view
    When she presses Esc
    Then the full curriculum tree restores with no filter active

  # ---- Lock Screen ----

  Scenario: Locked lesson shows WHY it is locked with prerequisite content
    Given Ana navigates to Lesson 7 (locked, requires Lesson 6)
    When she presses Enter
    Then a lock screen loads (not an error message)
    And the screen shows "Requires: L6 Method Definition (not yet complete)"
    And the screen shows what topics Lesson 7 covers
    And the screen shows what topics Lesson 6 covers (so she can evaluate the prerequisite)
    And pressing Enter navigates her to Lesson 6

  Scenario: Lock screen handles multiple prerequisites showing partial completion
    Given Lesson 10 requires both Lesson 8 and Lesson 9
    And Lesson 8 is complete but Lesson 9 is not
    When Ana selects Lesson 10
    Then the lock screen shows "L8 Method Objects (complete)" marked as done
    And it shows "L9 Procs and Lambdas (not yet complete)" marked as needed
    And pressing Enter navigates to Lesson 9 (the incomplete prerequisite)

  Scenario: No force-skip mechanism exists for locked lessons
    Given Ana is on a lock screen for a locked lesson
    Then there is no "skip prerequisite" or "unlock anyway" option
    And the only actions available are [Enter] (go to prerequisite) and [Esc] (back)
    And this is by design — prerequisite gates are absolute

  # ---- Prerequisite Lesson Flow ----

  Scenario: Completing prerequisite lesson updates lock states immediately
    Given Ana has navigated to and completed all exercises in Lesson 6
    When the Lesson 6 complete screen renders
    Then Lesson 7 is shown as newly unlocked
    And the curriculum tree (if reopened) shows Lesson 7 as available
    And the change is persisted before the unlock notification renders

  Scenario: SM-2 records exercises from topic-selection path with equal weight
    Given Ana completes Lesson 6 exercises via the topic selection path
    When she completes an exercise correctly
    Then SM-2 records the result with the same weight as a daily session exercise
    And Lesson 6 exercises appear in future review queues at normal intervals

  # ---- Unlock Notification ----

  Scenario: Unlock screen offers immediate start of target lesson
    Given Ana has completed Lesson 6
    When the lesson complete screen renders
    Then she sees Lesson 7 listed as newly unlocked
    And pressing Enter starts Lesson 7 immediately
    And pressing Esc returns to the session dashboard with L7 saved as next session

  Scenario: Unlock persists across sessions
    Given Ana has unlocked Lesson 7 by completing Lesson 6
    And she pressed Esc to save for next session
    When she opens the platform the following day
    Then Lesson 7 is still shown as available (not locked again)
    And the session dashboard recommends Lesson 7 as the next lesson

  # ---- Target Lesson ----

  Scenario: Target lesson available for full study after prerequisite completed
    Given Ana has completed Lesson 6 and Lesson 7 is now unlocked
    When she starts Lesson 7
    Then the full lesson with exercises is available (not preview-only)
    And the lesson content shows Python callable patterns before Ruby block syntax
    And there is no explanation of what a function or anonymous function is

  # ---- Session Integration ----

  Scenario: Topic selection via [t] override preserves SM-2 review queue
    Given Ana is on the session dashboard
    When she presses "t" to open topic selection
    And she selects an available lesson different from the SM-2 recommendation
    And she starts the session
    Then the review queue runs first (unchanged from SM-2 plan)
    And the manually selected lesson runs after the review queue

  Scenario: Session summary shows all completed lessons for topic-selection sessions
    Given Ana completed both Lesson 6 (prerequisite) and Lesson 7 (target) in one sitting
    When the session complete screen renders
    Then it shows both Lesson 6 and Lesson 7 as completed today
    And SM-2 records exercises from both lessons

  # ---- Property Scenarios ----

  @property
  Scenario: Lock state is consistent across all views
    Given a lesson's completion status changes (lesson is marked complete)
    Then within the same session, all views reflecting that lesson's status are consistent:
      | View | Artifact |
      | Curriculum tree | lesson_status icon |
      | Session dashboard | next_lesson recommendation |
      | Lock screen for dependent lessons | prerequisite_completion_status |
      | Progress dashboard | lessons_complete count |

  @property
  Scenario: Prerequisite graph is acyclic and correctly ordered
    Given the full curriculum prerequisite graph
    Then no lesson is a prerequisite of itself (no cycles)
    And all prerequisite references point to lower-numbered lessons
    And completing lessons in sequential order always satisfies all prerequisites
