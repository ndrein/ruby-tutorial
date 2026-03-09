# Integration Checkpoints — Cross-Domain Flows
#
# These scenarios validate behaviors that cross module boundaries and cannot be
# fully covered within a single milestone feature file.
#
# Driving ports: Multiple controllers exercised in sequence
# Integration points: sm2 ↔ session ↔ curriculum ↔ progress
#
# All scenarios @skip until all individual milestone walking skeletons pass.

Feature: Cross-domain behaviors are consistent and correct end to end
  As an experienced developer relying on the platform for daily practice
  I want behaviors that span multiple domains to work together correctly
  So that my review schedule, progress, and lesson state are always consistent

  # ---- SM-2 + Session + Curriculum ----

  @skip
  Scenario: Session plan includes correct lesson after completing a prerequisite in the same session
    Given Ana completed Lesson 5 (unlocking Lesson 6) at the end of yesterday's session
    When Ana opens the platform today
    Then the session dashboard shows Lesson 6 as today's new lesson
    And the session plan does not show any already-completed lessons

  @skip
  Scenario: Exercises from both daily sessions and topic-selection paths appear in the same review queue
    Given Ana completed Lesson 4 exercises via the daily session path
    And she completed Lesson 6 exercises via the topic selection path the same day
    When the review queue is computed the next day
    Then it includes due exercises from both Lesson 4 and Lesson 6
    And the intervals for both sets of exercises reflect the SM-2 algorithm equally

  # ---- SM-2 + Progress ----

  @skip
  Scenario: Progress dashboard retention score reflects exercises completed in the current session
    Given Ana completed Lesson 3 review exercises with 8 out of 10 correct in today's session
    When she opens the progress dashboard after the session completes
    Then Lesson 3 shows a retention score of 80%
    And this score reflects the 10 most recent reviews, including today's

  @skip
  Scenario: Streak increments only after session state is fully persisted
    Given Ana has a 7-day streak
    And she completes today's session
    When the session is fully saved to storage
    Then the streak shows 8 days
    And if the platform had been interrupted before saving, the streak would still show 7 days

  # ---- Lesson Tree + SM-2 ----

  @skip
  Scenario: Completing a lesson initializes SM-2 entries for all its exercises
    Given Lesson 6 has 3 exercises and none have SM-2 entries yet
    When Ana completes all 3 exercises in Lesson 6
    Then all 3 exercises have SM-2 entries with initial ease factor 2.5 and interval 1 day
    And all 3 exercises appear in tomorrow's review queue

  @skip
  Scenario: SM-2 urgency ordering works correctly when exercises from different lessons are due
    Given exercises from Lessons 1, 3, and 4 are all due today
    And the Lesson 1 exercise is 3 days overdue
    And the Lesson 3 exercise is due exactly today
    And the Lesson 4 exercise is 1 day overdue
    When the session starts
    Then the review order is Lesson 1, then Lesson 4, then Lesson 3

  # ---- Atomicity ----

  @skip
  Scenario: Lesson completion and prerequisite unlock are atomic with no intermediate state
    Given Ana has just submitted the last correct answer in Lesson 6
    When the lesson complete screen begins rendering
    Then at the moment the completion screen is visible Lesson 7 is already unlocked
    And there is no point in time where Lesson 6 shows as complete but Lesson 7 still shows as locked

  @skip
  Scenario: All SM-2 updates from a session are committed together on session complete
    Given Ana has completed a full session with 6 reviews and 3 lesson exercises
    When she presses Enter to exit the session summary
    Then all 9 exercise SM-2 states are persisted in a single operation
    And if the persist operation fails, none of the 9 states are partially written

  # ---- Performance Checkpoint ----

  @skip
  Scenario: Session dashboard renders within 500ms including SM-2 queue computation
    Given Ana has 12 exercises due today and Lesson 8 is next
    When she opens the platform
    Then the session dashboard is fully rendered with the review count and lesson title within 500 milliseconds

  @skip
  Scenario: SM-2 daily queue computation completes within the performance target
    Given up to 12 exercises are due today
    When the review queue is computed
    Then the computation finishes within 200 milliseconds

  # ---- Curriculum Tree + Progress ----

  @skip
  Scenario: Progress dashboard and curriculum tree show the same lesson completion status
    Given Ana has completed Lessons 1 through 8
    When she opens both the progress dashboard and the curriculum tree in the same session
    Then the progress dashboard shows "8/25 lessons complete"
    And the curriculum tree shows exactly 8 lessons with the "complete" status icon
    And the two counts match

  # ---- Session Interruption Recovery ----

  @skip
  Scenario: Closing the browser mid-session and reopening shows the correct session state
    Given Ana has completed 4 of 6 review exercises in the current session
    When she closes the browser completely and reopens the platform
    Then the 4 completed review exercises retain their updated SM-2 intervals
    And the session can be continued from the 5th review exercise
