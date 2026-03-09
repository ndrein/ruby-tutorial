# Walking Skeleton — Ruby Learning Platform
#
# These 3 scenarios prove that Ana can accomplish her primary goals end-to-end.
# Each answers: "Can a user accomplish this goal and see the result?"
# Demo-able to stakeholders without technical explanation.
#
# All other scenarios in milestone feature files are @skip until a walking
# skeleton passes. Enable one scenario at a time per the implementation sequence
# in docs/feature/ruby-learning-platform/distill/walking-skeleton.md.

@walking_skeleton
Feature: Ana completes her first Ruby learning session
  As an experienced developer learning Ruby
  I want to open the platform, complete a lesson, and see my progress recorded
  So that I know the platform works and my practice is building toward fluency

  @walking_skeleton
  Scenario: Ana opens the platform for the first time and completes her first exercise
    Given Ana opens the Ruby Learning Platform for the first time
    When the platform launches
    Then she sees a welcome screen acknowledging her existing expertise
    And she can navigate to Lesson 1 "Syntax Differences" without any login
    And she can start an exercise that has a 30-second countdown timer
    And submitting a correct answer shows her "Correct." with a Ruby-specific explanation
    And her result is saved so tomorrow she will see a review exercise

  @walking_skeleton @skip
  Scenario: Ana completes a daily session with review exercises and a new lesson
    Given Ana has completed Lesson 1 three days ago
    And she has 3 review exercises due today from Lesson 1
    And the next available lesson is Lesson 2 "String Interpolation"
    When Ana opens the platform for her daily session
    Then the session dashboard shows her review count and the next lesson title
    And she can complete all review exercises in urgency order
    And she can complete Lesson 2 exercises
    And the session summary shows her total exercises completed and current streak
    And her SM-2 schedule is updated so review dates reflect today's performance

  @walking_skeleton @skip
  Scenario: Ana looks up a topic she needs for work and completes the prerequisite lesson
    Given Ana has completed Module 1 but needs to learn about Ruby blocks immediately
    And Lesson 7 "Blocks and Yield" requires Lesson 6 "Method Definition" to be complete
    And Lesson 6 is currently available
    When Ana opens the curriculum tree and navigates to Lesson 7
    Then she sees a lock screen explaining that Lesson 6 is the prerequisite
    And pressing Enter navigates her to Lesson 6
    And completing Lesson 6 immediately unlocks Lesson 7
    And she can start Lesson 7 in the same session
