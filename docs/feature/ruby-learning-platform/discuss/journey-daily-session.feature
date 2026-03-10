# Journey: Daily Session — Ruby Learning Platform
# Persona: Marcus Chen (week 1 established user; 6-day streak entering session)
# Emotional Arc: Intent → Flow → Satisfaction → Streak Pride
# Job Stories: JS-2 (Daily Habit), JS-3 (Automated Review Queue)

Feature: Daily Session — Email Trigger Through Session Summary

  As Marcus Chen, an established platform user with a 6-day streak,
  I want to receive my morning email, open the app, complete my SM-2 review queue,
  optionally read a new lesson, and reach a session summary under 15 minutes,
  So that I feel productive, on-schedule, and proud of maintaining my streak.

  Background:
    Given Marcus has a platform account with expert mode enabled
    And Marcus has completed Lessons 1 and 2 and their exercises
    And Marcus has 8 concepts in his SM-2 review pool
    And Marcus's streak is currently 6 days
    And today is a scheduled review day for 4 concepts (Ruby Symbols, Blocks, attr_accessor, Comparable)
    And Marcus has configured his daily email to arrive at 8:00 AM

  # -----------------------------------------------------------------------
  # Step 1: Email Arrival and Queue Preview
  # -----------------------------------------------------------------------

  Scenario: Daily email arrives with queue count and time estimate in subject line
    Given it is 8:00 AM on Marcus's scheduled email delivery time
    When the platform sends Marcus's daily digest email
    Then Marcus receives an email with subject: "Today's Queue — 4 reviews + 1 lesson option"
    And the email body lists the 4 review exercises by concept name
    And the email shows an estimated session time of 8-10 minutes
    And the email shows Marcus's current streak: 6 days
    And the email contains a single call-to-action link: "Open Today's Session"

  Scenario: Daily email does not arrive when review queue is empty
    Given Marcus has no exercises scheduled for review today
    And no new lessons are available
    When the daily email time arrives
    Then Marcus does not receive an email
    And the platform records that today's session was optionally skipped without breaking streak

  Scenario: Email delivery time is configurable per user preference
    Given Marcus has set his email delivery preference to 7:30 AM
    When 7:30 AM arrives
    Then Marcus receives his daily digest email at 7:30 AM
    And the email was not sent before 7:30 AM

  # -----------------------------------------------------------------------
  # Step 2: Session Start Screen
  # -----------------------------------------------------------------------

  Scenario: Clicking email link opens session start screen with full queue visible
    Given Marcus clicks the "Open Today's Session" link in his email
    When the platform loads the session start screen
    Then Marcus sees a list of today's 4 review exercises before starting
    And Marcus sees the optional new lesson (Lesson 3: Procs vs Lambdas)
    And Marcus sees his current time budget: 15 minutes 0 seconds
    And Marcus sees his current streak: 6 days
    And Marcus can start the review queue by pressing Enter

  Scenario: Session start screen is accessible without email link
    Given Marcus opens the platform directly (not via email link)
    When Marcus navigates to today's session
    Then Marcus sees the same session start screen as if he had clicked the email link
    And Marcus's session does not duplicate if he has already partially completed it today

  # -----------------------------------------------------------------------
  # Steps 3-6: Review Queue (SM-2 Exercises)
  # -----------------------------------------------------------------------

  Scenario: SM-2 review queue presents exercises in scheduled order
    Given Marcus starts the review queue
    When the first exercise appears
    Then Marcus sees exercise 1 of 4: Ruby Symbols vs Strings
    And Marcus sees a 30-second countdown timer
    And Marcus sees his position in the queue: "Review 1 of 4"
    And Marcus can submit by pressing Enter after typing his answer

  Scenario: Correct answer on review exercise updates SM-2 interval to next tier
    Given Marcus is on exercise 1: Ruby Symbols vs Strings
    And the concept's current SM-2 interval is 3 days
    When Marcus types a correct answer and presses Enter within 30 seconds
    Then the SM-2 interval for Ruby Symbols vs Strings increases (e.g., 7 days)
    And the new next_review_date is scheduled accordingly
    And Marcus advances to exercise 2 automatically after pressing Enter on feedback

  Scenario: Incorrect answer on review exercise resets SM-2 interval
    Given Marcus is on exercise 4: Comparable module
    And the concept's current SM-2 interval is 14 days
    When Marcus types an incorrect answer and presses Enter
    Then the SM-2 interval for Comparable resets to 1 day (re-review tomorrow)
    And Marcus sees the correct answer displayed with a plain-language explanation
    And Marcus can press Enter to advance to the queue summary

  Scenario: Timer expiry auto-advances exercise and marks as incomplete
    Given Marcus is on exercise 2: Blocks with yield
    And Marcus has not typed an answer
    When 30 seconds elapse
    Then the exercise auto-advances
    And the exercise is recorded as incomplete (treated same as incorrect for SM-2)
    And Marcus sees the correct answer and explanation before advancing

  Scenario: Marcus can mark an exercise as hard using keyboard shortcut
    Given Marcus is on exercise 3 and finds the recall difficult
    When Marcus presses "h" (mark as hard)
    Then the current exercise's timer pauses or extends by 15 seconds
    And the SM-2 score for this exercise will be treated as lower quality (harder)
    And Marcus's difficulty signal is recorded for SM-2 ease factor adjustment

  Scenario: Review exercises are keyboard-navigable throughout
    Given Marcus is in the review queue
    Then Marcus can complete all 4 exercises without touching the mouse
    And every interactive element has a visible focus state (2px+ ring)
    And pressing Tab moves focus to the answer input field
    And pressing Enter submits the answer

  # -----------------------------------------------------------------------
  # Step 7: Review Queue Complete
  # -----------------------------------------------------------------------

  Scenario: Queue summary shows per-exercise results and next review dates
    Given Marcus has completed all 4 review exercises
    When the queue summary screen appears
    Then Marcus sees a table with:
      | Concept                 | Result  | Next Review |
      | Ruby Symbols vs Strings | Correct | 7 days      |
      | Blocks with yield       | Correct | 14 days     |
      | attr_accessor           | Correct | 30 days     |
      | Comparable module       | Correct | 7 days      |
    And Marcus sees the total review time: 3 minutes 47 seconds
    And Marcus sees the remaining session budget: 11 minutes 13 seconds

  Scenario: Queue summary offers optional new lesson with time estimate
    Given Marcus has completed the review queue
    And Marcus has 11 minutes 13 seconds of budget remaining
    When Marcus sees the queue summary
    Then Marcus sees an offer to start Lesson 3: Procs vs Lambdas
    And the offer shows an estimated time: "~3 min"
    And Marcus can accept with Enter or decline with Esc
    And the lesson is described as optional — not prompted with urgency language

  # -----------------------------------------------------------------------
  # Steps 8-11: Optional New Lesson
  # -----------------------------------------------------------------------

  Scenario: New lesson loads with Python/Java side-by-side comparison
    Given Marcus accepts the offer to start Lesson 3: Procs vs Lambdas
    When the lesson view loads
    Then Marcus sees the lesson content within 2 seconds
    And the lesson includes a side-by-side comparison of Ruby procs/lambdas vs Python lambda
    And the lesson fits within the estimated 3-minute reading time

  Scenario: Lesson exercise follows the same keyboard-native pattern as review exercises
    Given Marcus has completed reading Lesson 3
    When Marcus advances to the lesson exercise
    Then Marcus sees a fill-in-the-blank or multiple-choice exercise
    And the exercise has a 30-second timer
    And Marcus can submit with Enter and skip with Esc

  Scenario: Completing lesson exercise triggers SM-2 first scheduling
    Given Marcus completes the Lesson 3 exercise with a correct answer
    When the SM-2 scheduling confirmation appears
    Then Marcus sees: "Procs vs Lambdas scheduled for review on [today + 3 days]"
    And Marcus sees the plain-language reason: "First exposure — short interval to confirm retention"
    And the concept is added to Marcus's review pool with initial SM-2 parameters

  # -----------------------------------------------------------------------
  # Step 12: Session Summary
  # -----------------------------------------------------------------------

  Scenario: Session summary shows full metrics within 15-minute target
    Given Marcus has completed the review queue and Lesson 3
    When the session summary screen appears
    Then Marcus sees:
      | Metric                  | Value              |
      | Reviews completed       | 4 of 4             |
      | New lesson completed    | Lesson 3           |
      | Total session time      | 11 min 24 sec      |
      | Daily target            | 15 min             |
      | Under target by         | 3 min 36 sec       |
      | Streak                  | 7 days             |
    And Marcus sees the streak has incremented from 6 to 7 days

  Scenario: Streak increments exactly once per calendar day
    Given Marcus completed a session earlier today (streak currently 7)
    When Marcus opens the app again later the same day and views the dashboard
    Then Marcus's streak remains at 7 days
    And no additional session is required to maintain the day's streak credit

  Scenario: Session hard cap prevents queue from exceeding 15 minutes
    Given Marcus has used 14 minutes of his session budget
    When Marcus has 1 minute of budget remaining
    Then the platform does not start a new lesson if the estimate exceeds 1 minute
    And Marcus sees: "Session target reached — you're done for today"
    And the review queue auto-completes if any remaining exercises exceed the budget

  Scenario: Session summary navigation is keyboard-accessible
    Given Marcus is on the session summary screen
    When Marcus presses "g d"
    Then Marcus navigates to the progress dashboard
    When Marcus presses Esc from the session summary
    Then Marcus returns to the home screen

  # -----------------------------------------------------------------------
  # Full Daily Session Happy Path
  # -----------------------------------------------------------------------

  Scenario: Marcus completes full daily session under 15 minutes keyboard-only
    Given Marcus opens the platform from his email link at 8:47 AM
    When Marcus completes the full daily session
    Then Marcus reviews 4 exercises (SM-2 queue) using keyboard only
    And Marcus reads Lesson 3 and completes its exercise using keyboard only
    And Marcus reaches the session summary showing under 15 minutes total
    And Marcus's streak shows 7 days
    And Marcus has not touched the mouse at any point
    And all SM-2 intervals have been updated in the review pool
