# Journey: Topic Selection / Curriculum Navigation — Ruby Learning Platform
# Persona: Marcus Chen (week 2; 14-day streak; 8 lessons complete)
# Emotional Arc: Curiosity → Orientation → Agency → Anticipation
# Job Stories: JS-1 (Syntax Transfer), JS-5 (Progress Visibility)

Feature: Topic Selection — Curriculum Navigation and Progress Orientation

  As Marcus Chen, a two-week platform user with 14 daily sessions complete,
  I want to explore the curriculum, understand where I am in the full arc,
  see prerequisite gates clearly, and select my next lesson with confidence,
  So that I feel oriented within the 25-lesson curriculum and motivated to continue.

  Background:
    Given Marcus has a platform account with expert mode enabled
    And Marcus has completed 8 lessons (Lessons 1-8)
    And Marcus has 12 concepts mastered, 8 in review, 4 new in his SM-2 pool
    And Marcus has a 14-day streak
    And Marcus's retention rate is 73% (correct on SM-2 reviews, last 14 days)
    And Lesson 9 (Method Objects) is available for Marcus to study
    And Lesson 15 (method_missing) requires Lessons 11-14 as prerequisites

  # -----------------------------------------------------------------------
  # Steps 1-3: Dashboard — Progress Overview
  # -----------------------------------------------------------------------

  Scenario: Dashboard shows mastery counts with visual progress context
    Given Marcus navigates to the progress dashboard
    When the dashboard view loads
    Then Marcus sees:
      | Metric               | Value              |
      | Mastered concepts    | 12                 |
      | In Review concepts   | 8                  |
      | New concepts         | 4                  |
      | Lessons completed    | 8 of 25            |
      | Streak               | 14 days            |
      | Retention rate       | 73%                |
    And Marcus sees a visual progress bar for lessons: "8 of 25 (32%)"
    And Marcus sees a visual breakdown for concept statuses
    And the dashboard has a keyboard shortcut to navigate to curriculum: "c"

  Scenario: Retention rate is shown with a plain-language calculation explanation
    Given Marcus is viewing the progress dashboard
    When Marcus reads the retention rate metric
    Then Marcus sees: "Retention Rate: 73%"
    And Marcus sees beneath it: "Percentage of SM-2 review answers that were correct, last 14 days"
    And Marcus can understand the metric without reading any documentation

  Scenario: Dashboard provides navigation shortcuts to key areas
    Given Marcus is on the dashboard
    When Marcus presses "c"
    Then Marcus navigates to the curriculum overview
    When Marcus presses "s"
    Then Marcus navigates to today's session start screen

  # -----------------------------------------------------------------------
  # Step 4: Curriculum Map
  # -----------------------------------------------------------------------

  Scenario: Curriculum overview shows all 5 modules with status per lesson
    Given Marcus navigates to the curriculum overview
    When the curriculum view loads
    Then Marcus sees all 5 modules listed with progress counts
    And Marcus sees each lesson within expanded modules with a status indicator:
      | Status     | Icon | Meaning                              |
      | Mastered   | [x]  | SM-2 interval >= 30 days             |
      | In Review  | [~]  | SM-2 interval 3-29 days              |
      | New        | [>]  | Completed once; not yet reviewed     |
      | Available  | [ ]  | Prerequisites met; not started       |
      | Locked     | [L]  | Prerequisites not met                |
    And Marcus can navigate lessons with j/k keys
    And Marcus can open a lesson detail with Enter

  Scenario: Curriculum overview shows Marcus's current position clearly
    Given Marcus opens the curriculum overview
    Then Lesson 9 (Method Objects) is marked as "NEXT" or "Available"
    And Lesson 8 (Procs and Lambdas — `->` syntax) is marked as "In Review" or "Mastered"
    And Lesson 10 (Enumerable) is marked as "Locked"

  Scenario: Curriculum is grouped into modules with module-level progress
    Given Marcus is viewing the curriculum overview
    Then Marcus sees Module 1 with a progress indicator: "5/5 complete"
    And Marcus sees Module 2 with a progress indicator: "3/5 complete"
    And Marcus sees Modules 3, 4, 5 as locked with 0/5 progress each
    And Marcus can see module titles even when modules are locked

  Scenario: Curriculum navigation is fully keyboard-accessible
    Given Marcus is on the curriculum overview
    Then Marcus can expand a module using Enter
    And Marcus can navigate between lessons using j/k
    And Marcus can open a lesson detail using Enter
    And Marcus can return to the previous view using Esc
    And no mouse interaction is required

  # -----------------------------------------------------------------------
  # Step 5: Prerequisite Gate
  # -----------------------------------------------------------------------

  Scenario: Locked lesson shows which prerequisites are needed with completion status
    Given Marcus selects Lesson 15 (method_missing) from the curriculum
    When the lesson detail view opens
    Then Marcus sees the status: "LOCKED"
    And Marcus sees a list of required prerequisites:
      | Prerequisite     | Status               |
      | Lesson 11        | Not completed        |
      | Lesson 12        | Not completed        |
      | Lesson 13        | Not completed        |
      | Lesson 14        | Not completed        |
    And Marcus sees an estimate: "Complete 4 prerequisite lessons — approximately 3 daily sessions"
    And Marcus does not see a confusing generic "locked" message without context

  Scenario: Partially completed prerequisites show remaining work
    Given Marcus has completed Lesson 11 but not 12, 13, or 14
    When Marcus opens the Lesson 15 detail view
    Then Marcus sees Lesson 11 marked as completed in the prerequisite list
    And Marcus sees Lessons 12, 13, 14 as not completed
    And Marcus sees the updated estimate: "3 more prerequisite lessons needed"

  Scenario: Completing the last prerequisite unlocks a lesson immediately
    Given Marcus has completed Lessons 11, 12, and 13 and is completing Lesson 14
    When Marcus completes Lesson 14's exercise and receives SM-2 scheduling
    Then Lesson 15 becomes available (status changes from Locked to Available)
    And Marcus sees Lesson 15 in his curriculum as unlocked on next page load

  # -----------------------------------------------------------------------
  # Step 6: Lesson Detail Card
  # -----------------------------------------------------------------------

  Scenario: Lesson detail card shows topic, time estimate, and cross-language mapping
    Given Marcus selects Lesson 9 (Method Objects) from the curriculum
    When the lesson detail card opens
    Then Marcus sees:
      | Field             | Value                                          |
      | Lesson number     | 9                                              |
      | Title             | Method Objects and &method(:name)              |
      | Module            | Module 2: Ruby Methods and Blocks              |
      | Status            | Available (prerequisites met)                  |
      | Estimated time    | ~4 minutes                                     |
      | Python equivalent | functools, partial, direct reference           |
      | Java equivalent   | Method references (::)                         |
      | Exercise type     | Fill-in-the-blank (30 seconds)                 |
    And Marcus sees a brief description of what the lesson teaches
    And Marcus does not see any lesson content before selecting it

  Scenario: Available lesson can be started immediately or queued for next session
    Given Marcus is viewing the Lesson 9 detail card
    When Marcus reviews his options
    Then Marcus sees two actions:
      | Action                | Key   |
      | Start now             | Enter |
      | Queue for next session | q     |
    And Marcus can press Esc to return to curriculum without selecting

  # -----------------------------------------------------------------------
  # Step 7: Lesson Selection and Queue
  # -----------------------------------------------------------------------

  Scenario: Selecting "Queue for next session" adds lesson to tomorrow's session
    Given Marcus presses "q" on the Lesson 9 detail card
    When Marcus views tomorrow's session start screen
    Then Lesson 9 appears in the optional lesson slot for tomorrow's session
    And the session start screen shows: "Optional lesson: Lesson 9 — Method Objects (~4 min)"

  Scenario: User can only queue one lesson per session slot
    Given Marcus has already queued Lesson 9 for tomorrow
    When Marcus tries to queue Lesson 10 (if available) for tomorrow
    Then Marcus sees a message: "You already have Lesson 9 queued for tomorrow"
    And Marcus can replace the queue with Lesson 10 or keep Lesson 9

  # -----------------------------------------------------------------------
  # Steps 8-9: Module Progress and Full Arc
  # -----------------------------------------------------------------------

  Scenario: Module progress view shows lesson-by-lesson path and unlock dependencies
    Given Marcus opens the Module 2 progress view
    When the module view loads
    Then Marcus sees progress: "3 of 5 lessons complete"
    And Marcus sees a visual progress bar for Module 2
    And Marcus sees each lesson's status within the module
    And Marcus sees which lesson completion unlocks the next lesson
    And Marcus sees: "Completing Lesson 9 unlocks Lesson 10 (Enumerable)"
    And Marcus sees: "Completing Lesson 10 unlocks Module 3"

  Scenario: Future locked modules show titles to maintain motivation
    Given Marcus is viewing the curriculum overview
    When Marcus scrolls to Modules 4 and 5 (locked)
    Then Marcus sees the module titles: "Ruby Idioms" and "Ruby Standard Library Essentials"
    And Marcus sees the lesson titles within locked modules (but not lesson content)
    And Marcus sees that Module 4 contains "Pattern Matching (Ruby 3+)"
    And Marcus does not see a blank or "coming soon" placeholder

  # -----------------------------------------------------------------------
  # Step 10: Return to Dashboard
  # -----------------------------------------------------------------------

  Scenario: Return to dashboard shows updated queue after lesson selection
    Given Marcus has queued Lesson 9 for tomorrow
    When Marcus presses Esc to return to the dashboard
    Then Marcus sees his dashboard reflecting the same mastery counts and streak
    And the dashboard shows a "Tomorrow's session" preview if a lesson has been queued

  # -----------------------------------------------------------------------
  # Full Topic Selection Happy Path
  # -----------------------------------------------------------------------

  Scenario: Marcus navigates curriculum, selects next lesson, without touching mouse
    Given Marcus is on the progress dashboard
    When Marcus completes the full topic selection flow
    Then Marcus presses "c" to navigate to the curriculum overview
    And Marcus uses j/k to navigate to Lesson 9
    And Marcus presses Enter to open the Lesson 9 detail card
    And Marcus presses "q" to queue it for the next session
    And Marcus presses Esc to return to the curriculum
    And Marcus scrolls through to see Modules 4 and 5 titles
    And Marcus presses Esc to return to the dashboard
    And Marcus has not touched the mouse at any point
    And Lesson 9 appears in tomorrow's session queue
