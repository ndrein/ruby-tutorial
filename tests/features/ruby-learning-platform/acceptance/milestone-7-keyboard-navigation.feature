# Milestone 7: Keyboard Navigation (US-07)
#
# Covers: AC-07-01 through AC-07-10
# Driving ports: All controllers (keyboard nav is cross-cutting)
#                Validated through the web layer primary adapters
#
# All scenarios @skip until milestone-1 onboarding scenarios pass.

Feature: Every application action is reachable and operable without a mouse
  As a developer who uses keyboard-native tools professionally
  I want all platform actions available via keyboard shortcuts
  So that I can practice Ruby without breaking my keyboard-only workflow

  # ---- Global Access (AC-07-04, AC-07-05, AC-07-07) ----

  @skip
  Scenario: Pressing Esc goes back or cancels from any screen
    Given Ana is on any screen in the application
    When she presses Esc
    Then she navigates to the previous screen or the action is cancelled
    And no data loss occurs from pressing Esc on any screen

  @skip
  Scenario: Pressing "?" shows the keyboard shortcut overlay from any screen
    Given Ana is on any screen
    When she presses "?"
    Then a keyboard shortcut reference overlay appears
    And the overlay lists all shortcuts with their action descriptions
    When she presses Esc
    Then the overlay closes and she is on the same screen as before

  @skip
  Scenario: Pressing "p" opens the progress dashboard from any screen
    Given Ana is on any screen in the application
    When she presses "p"
    Then the progress dashboard opens as an overlay
    And pressing Esc closes the overlay and returns her to her previous context

  # ---- Session Dashboard Shortcuts (AC-07-08) ----

  @skip
  Scenario: Pressing "t" from the session dashboard opens topic selection
    Given Ana is on the session dashboard
    When she presses "t"
    Then the topic selection view opens
    And the review queue from the session plan is unchanged

  # ---- Session Complete Shortcut (AC-07-06 partial) ----

  @skip
  Scenario: Pressing "n" from the session complete screen starts the next lesson
    Given Ana is on the session complete screen
    When she presses "n"
    Then the next available lesson starts immediately

  # ---- List Navigation (AC-07-01, AC-07-02) ----

  @skip
  Scenario: j and k navigate up and down in the curriculum tree
    Given Ana is in the curriculum tree
    When she presses "j" five times
    Then the cursor is on the lesson 5 positions below the starting position
    When she presses "k" three times
    Then the cursor is on the lesson 3 positions above that

  @skip
  Scenario: J and K (shift) jump between module boundaries
    Given Ana is in the curriculum tree with the cursor on Lesson 1
    When she presses "J" (shift-j)
    Then the cursor moves to Lesson 6, the first lesson of Module 2
    When she presses "J" (shift-j) again
    Then the cursor moves to Lesson 11, the first lesson of Module 3

  @skip
  Scenario: Enter selects the highlighted lesson in the curriculum tree
    Given Ana is in the curriculum tree with the cursor on Lesson 6
    When she presses Enter
    Then Lesson 6 opens (either the preview or the lock screen)
    And she does not need to use a mouse to confirm the selection

  # ---- Search Shortcut (AC-07-09) ----

  @skip
  Scenario: Pressing "/" in the curriculum tree opens inline keyword search
    Given Ana is in the curriculum tree
    When she presses "/"
    Then a search input field becomes active
    And she can type to filter the curriculum tree

  # ---- Exercise Hint Shortcut (AC-07-10) ----

  @skip
  Scenario: Pressing Tab shows a hint in the exercise view
    Given Ana is on any exercise screen
    When she presses Tab
    Then a partial hint appears for the current exercise
    And the hint does not reveal the complete answer

  # ---- Focus Indicators (AC-07-06) ----

  @skip
  Scenario: All interactive elements have visible focus indicators when navigated by keyboard
    Given Ana tabs through any screen in the application
    Then every focused element shows a visible focus indicator
    And the focus indicator is clearly distinguishable from the browser default outline

  @skip
  Scenario: Focus returns to the triggering element when an overlay closes
    Given Ana opened the "?" shortcut overlay from the curriculum tree
    When she presses Esc to close the overlay
    Then keyboard focus returns to the curriculum tree element that had focus before

  # ---- No Mouse Required ----

  @skip
  Scenario: Ana can complete a full daily session from start to finish without using a mouse
    Given Ana opens the platform
    When she completes a full session including reviews and a new lesson
    Then every action from opening to the session complete screen was performed using keyboard only
    And no modal, dropdown, or interactive element required a mouse click at any point

  @skip
  Scenario: No more than 3 keypresses are needed to reach any action from any screen
    Given Ana is on any screen in the application
    Then any primary action in the application is reachable within 3 keypresses
    And this holds regardless of which screen she is currently on
