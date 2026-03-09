# Milestone 6: Progress Dashboard (US-09)
#
# Covers: AC-09-01 through AC-09-06
# Driving ports: ProgressController (→ ProgressDashboard)
#
# All scenarios @skip until milestone-2 daily session scenarios pass.

Feature: Progress dashboard shows real retention data without gamification
  As an experienced developer building a practice habit
  I want to see where I actually stand in my Ruby learning
  So that I can make informed decisions about my practice without false motivation

  Background:
    Given Ana has completed Lessons 1 through 5
    And she has a 14-day practice streak

  # ---- Dashboard Access (AC-09-05) ----

  @skip
  Scenario: Pressing "p" from any screen opens the progress dashboard as an overlay
    Given Ana is in the middle of a review session
    When she presses "p"
    Then the progress dashboard opens as an overlay on top of the current screen
    And the review session state is fully preserved underneath

  @skip
  Scenario: Pressing Esc closes the progress dashboard and restores the previous screen
    Given Ana has opened the progress dashboard with "p" during a session
    When she presses Esc
    Then the progress dashboard overlay closes
    And the review session is exactly where she left it

  @skip
  Scenario: Pressing "p" from the welcome screen also opens the progress dashboard
    Given Ana is on the welcome screen
    When she presses "p"
    Then the progress dashboard opens

  # ---- Lesson Completion Count (AC-09-01, AC-09-02) ----

  @skip
  Scenario: Dashboard shows the accurate lesson completion count
    When Ana opens the progress dashboard
    Then she sees "5/25 lessons complete"
    And Module 1 shows "5/5"
    And Modules 2 through 5 each show "0/N" reflecting zero completed lessons

  @skip
  Scenario: Dashboard lesson count updates immediately after a lesson is completed
    Given Ana has just completed Lesson 6
    When she opens the progress dashboard
    Then she sees "6/25 lessons complete"
    And Module 2 shows "1/5"

  # ---- Retention Score (AC-09-03) ----

  @skip
  Scenario: Retention score is calculated as correct reviews divided by total reviews for the last 10
    Given Lesson 3 exercises have been reviewed 10 times in total
    And 6 of those reviews were answered correctly
    When Ana opens the progress dashboard
    Then Lesson 3 shows a retention score of 60%
    And the score is labeled as "SM-2 retention (last 10 reviews)"

  @skip
  Scenario: Retention score uses all reviews when fewer than 10 have been recorded
    Given Lesson 5 has been reviewed 4 times in total
    And 3 of those reviews were answered correctly
    When Ana opens the progress dashboard
    Then Lesson 5 shows a retention score of 75%
    And the label indicates the score is based on the 4 available reviews

  @skip
  Scenario: Retention score is shown per completed lesson
    Given Ana has completed Lessons 1 through 5 with varying review histories
    When she opens the progress dashboard
    Then a retention score is shown for each of the 5 completed lessons
    And no score is shown for lessons that are locked or not yet started

  # ---- No Gamification (AC-09-04, AC-09-06) ----

  @skip
  Scenario: No gamification elements appear anywhere on the progress dashboard
    Given Ana has a 14-day streak and 90% average retention
    When she opens the progress dashboard
    Then no badges appear on screen
    And no XP or points values appear on screen
    And no level indicators appear on screen
    And no achievement notifications appear on screen
    And no congratulatory language beyond factual counts appears

  @skip
  Scenario: Streak is displayed as a plain count without highlighting it as an achievement
    When Ana opens the progress dashboard
    Then she sees "14 days" as the streak count
    And the streak is not highlighted with special color or animation
    And the streak is shown in the same visual style as other factual counts

  # ---- Sessions Remaining Estimate ----

  @skip
  Scenario: Dashboard shows an estimate of sessions remaining to complete the curriculum
    Given Ana has been completing approximately 1 lesson per day over the last 7 days
    When she opens the progress dashboard
    Then she sees an estimated sessions remaining count based on her current pace
    And the estimate is labeled as an approximation, not a guarantee

  # ---- Error and Edge Cases ----

  @skip
  Scenario: Progress dashboard shows correctly when no lessons have been completed yet
    Given Ana has not yet completed any lessons
    When she opens the progress dashboard
    Then she sees "0/25 lessons complete"
    And all modules show "0/N"
    And no retention scores are shown

  @skip
  Scenario: Retention score is not shown for lessons with no review history
    Given Lesson 2 has never been reviewed via SM-2
    When Ana opens the progress dashboard
    Then Lesson 2 shows its completion status but no retention score
    And no placeholder score (such as 0% or N/A) is shown as a retention score
