# Journey: Onboarding — Ruby Learning Platform
# Persona: Marcus Chen (senior Python/Java developer, first visit)
# Emotional Arc: Skepticism → Recognition → Competence → Commitment
# Job Stories: JS-1 (Syntax Transfer), JS-2 (Daily Habit)

Feature: Onboarding — Expert Developer First Visit

  As Marcus Chen, an experienced Python/Java developer,
  I want to arrive at the platform, recognize it is calibrated for me,
  complete my first lesson and exercise, and see SM-2 schedule my first review,
  So that I feel committed to returning tomorrow and trust the tool with my daily practice.

  Background:
    Given Marcus is an experienced developer with Python and Java background
    And Marcus has not previously registered on the platform
    And the platform has a 25-lesson expert-calibrated Ruby curriculum available

  # -----------------------------------------------------------------------
  # Step 1-2: Arrival and Curriculum Recognition
  # -----------------------------------------------------------------------

  Scenario: Expert developer recognizes calibrated content from curriculum preview
    Given Marcus arrives at the landing page for the first time
    When Marcus reads the headline and navigates to the curriculum overview
    Then Marcus sees Lesson 1 is "Ruby Blocks" — not "Variables" or "Data Types"
    And Marcus sees the curriculum explicitly states: "Assumes you know Python or Java"
    And Marcus sees the topics list includes: Blocks, Procs, Symbols, Enumerable, Pattern Matching
    And Marcus does not see any lesson titled "Introduction to Programming" or "What is a Variable"

  Scenario: Landing page communicates UVP within 10 seconds
    Given Marcus arrives at the landing page
    Then Marcus sees a headline that communicates the expert-calibrated positioning
    And Marcus sees a list of what the platform skips (variables, loops, OOP basics)
    And Marcus sees a list of what the platform teaches (blocks, procs, symbols, Enumerable)
    And Marcus can navigate to the curriculum overview using the keyboard without clicking

  # -----------------------------------------------------------------------
  # Step 3-4: Account Creation and Experience Confirmation
  # -----------------------------------------------------------------------

  Scenario: Account creation requires only email address
    Given Marcus decides to register
    When Marcus navigates to the sign-up flow
    Then Marcus sees a form with only one required field: email address
    And Marcus does not see fields for: name, phone number, job title, or company
    And Marcus can submit the form by pressing Enter without clicking a button

  Scenario: Expert mode is confirmed with a single question
    Given Marcus has submitted his email address
    When Marcus is shown the experience confirmation question
    Then Marcus sees exactly one question: "Do you have experience with another programming language?"
    And Marcus sees selectable options including "Yes — Python, Java, or similar"
    And Marcus can select "Yes" using the keyboard (j/k keys)
    And Marcus can confirm with Enter
    And Marcus sees a note explaining that selecting "Yes" skips variables, OOP, and control flow basics

  Scenario: Expert mode selection persists to curriculum
    Given Marcus has confirmed "Yes — Python, Java, or similar" experience
    When Marcus navigates to the curriculum overview
    Then Marcus sees lessons starting at Lesson 1: Ruby Blocks
    And Marcus does not see any gating or "complete intro module first" messages
    And the platform routes Marcus directly to Module 1 of the expert track

  # -----------------------------------------------------------------------
  # Step 5: First Lesson
  # -----------------------------------------------------------------------

  Scenario: First lesson provides Python/Java side-by-side comparison
    Given Marcus has confirmed expert mode
    And Marcus opens Lesson 1: Ruby Blocks
    Then Marcus sees the lesson content within 2 seconds
    And the lesson includes a side-by-side comparison showing:
      | Language | Syntax                           |
      | Python   | [x * 2 for x in lst]             |
      | Java     | lst.stream().map(x -> x * 2)     |
      | Ruby     | lst.map { |x| x * 2 }            |
    And the lesson does not contain any section explaining what a loop or variable is
    And Marcus can advance to the exercise by pressing Enter

  Scenario: Lesson content reads in under 5 minutes
    Given Marcus opens Lesson 1: Ruby Blocks
    When Marcus reads the full lesson content at normal reading speed
    Then Marcus completes the lesson in 5 minutes or less
    And Marcus can answer the follow-up exercise without returning to the lesson text

  # -----------------------------------------------------------------------
  # Step 6-7: First Exercise
  # -----------------------------------------------------------------------

  Scenario: First exercise accepts keyboard-only interaction
    Given Marcus has completed reading Lesson 1: Ruby Blocks
    When Marcus is presented with Exercise 1.1 (fill-in-the-blank)
    Then Marcus sees the exercise prompt with a blank to fill in
    And Marcus sees a 30-second countdown timer
    And Marcus can type his answer directly into the input field
    And Marcus can submit by pressing Enter without clicking a Submit button
    And Marcus can skip by pressing Esc if he does not know the answer

  Scenario: Exercise timer counts down from 30 seconds
    Given Marcus is on Exercise 1.1
    When 30 seconds elapse without Marcus submitting
    Then the exercise auto-advances and marks the answer as incomplete
    And Marcus sees feedback indicating the time expired and showing the correct answer

  Scenario: Correct answer produces informative feedback
    Given Marcus types "select" as the answer to Exercise 1.1
    And Marcus presses Enter to submit
    When the platform evaluates the answer
    Then Marcus sees "Correct" confirmation
    And Marcus sees an explanation of why "select" is correct in this context
    And the explanation references the Python/Java equivalent (filter function, stream filter)
    And Marcus can press Enter to advance to the SM-2 scheduling confirmation

  Scenario: Incorrect answer produces helpful feedback without humiliating Marcus
    Given Marcus types an incorrect answer to Exercise 1.1
    And Marcus presses Enter to submit
    When the platform evaluates the answer
    Then Marcus sees the correct answer displayed
    And Marcus sees an explanation connecting the correct answer to Python/Java equivalents
    And the feedback does not contain phrases like "Wrong!" or "Try again"
    And Marcus can press Enter to advance to the SM-2 scheduling confirmation

  # -----------------------------------------------------------------------
  # Step 8: SM-2 Scheduling
  # -----------------------------------------------------------------------

  Scenario: SM-2 schedules first review in plain language
    Given Marcus has submitted his answer to Exercise 1.1
    When Marcus reaches the SM-2 scheduling confirmation screen
    Then Marcus sees a message: "Ruby Blocks will be reviewed on [date 3 days from now]"
    And Marcus sees a plain-language explanation: "First exposure — short interval to confirm retention"
    And Marcus sees the date is exactly 3 days from today
    And Marcus does not see any numerical SM-2 parameters (ease factor, repetition count)

  Scenario: SM-2 scheduling creates entry in review queue
    Given Marcus has completed Exercise 1.1 with any answer (correct or incorrect)
    When the SM-2 scheduling confirmation is shown
    Then the platform has created a review queue entry for Exercise 1.1
    And the entry is scheduled for 3 days from today (correct answer) or 1 day (incorrect answer)
    And the entry will appear in Marcus's daily email queue on the scheduled date

  # -----------------------------------------------------------------------
  # Step 9: Session Summary
  # -----------------------------------------------------------------------

  Scenario: Session summary shows time taken vs 15-minute target
    Given Marcus has completed his first lesson and first exercise
    When Marcus reaches the session summary screen
    Then Marcus sees the total session duration in minutes and seconds
    And Marcus sees the 15-minute daily target displayed
    And Marcus sees how much time he has remaining within the target
    And Marcus sees his current streak: "1 day"
    And Marcus sees what is scheduled for tomorrow (Ruby Blocks review + Lesson 2 option)

  Scenario: Session summary navigation is keyboard-accessible
    Given Marcus is on the session summary screen
    When Marcus presses "g d"
    Then Marcus navigates to the progress dashboard
    When Marcus presses Esc
    Then Marcus is returned to the main menu or home screen

  # -----------------------------------------------------------------------
  # Step 10: Email Opt-in
  # -----------------------------------------------------------------------

  Scenario: Email opt-in is presented as habit trigger, not newsletter subscription
    Given Marcus is on the session summary screen
    When Marcus reads the email opt-in prompt
    Then Marcus sees the prompt framed as: "Get your daily review queue by email"
    And Marcus sees the description: "A short list of what to practice tomorrow, sent each morning"
    And Marcus does not see the words "newsletter", "updates", "promotional", or "marketing"
    And Marcus can confirm by pressing Enter or decline by pressing Esc

  Scenario: Email opt-in confirmation links to future review queue delivery
    Given Marcus confirms the email opt-in
    When March 12 (3 days from onboarding) arrives
    Then Marcus receives an email with a link to his review queue
    And the email contains: "Today's queue: 1 exercise (Ruby Blocks) — estimated 30 seconds"
    And the email does not contain promotional content

  # -----------------------------------------------------------------------
  # Full Onboarding Flow (Happy Path)
  # -----------------------------------------------------------------------

  Scenario: Marcus completes full onboarding without touching mouse
    Given Marcus visits the platform for the first time
    When Marcus completes the full onboarding flow
    Then Marcus arrives at the landing page (keyboard navigation available)
    And Marcus views the curriculum overview (Tab to link, Enter to navigate)
    And Marcus registers with email (Tab to field, types email, Enter to submit)
    And Marcus confirms expert mode (j to select "Yes", Enter to confirm)
    And Marcus reads Lesson 1 (Enter to advance to exercise)
    And Marcus completes Exercise 1.1 (types answer, Enter to submit)
    And Marcus sees SM-2 scheduling confirmation (Enter to advance)
    And Marcus reaches session summary (g d or Esc to navigate)
    And Marcus confirms email opt-in (Enter to confirm)
    And Marcus has not touched the mouse at any point during this flow
    And the total session duration is 15 minutes or less
