# Milestone 8: Lesson Content Standards (US-06)
#
# Covers: AC-06-01 through AC-06-05
# Driving ports: LessonsController (→ CurriculumMap)
#
# These scenarios validate the content standards that govern all 25 lessons.
# They are expressed as property-shaped checks across the curriculum.
# All scenarios @skip until milestone-1 onboarding scenarios pass.

Feature: Lesson content respects the learner's existing expertise
  As an experienced Python/Java developer learning Ruby
  I want every lesson to start from what I already know and map it to Ruby
  So that I learn the differences, not the fundamentals I have already mastered

  # ---- Comparison Format (AC-06-01) ----

  @skip
  Scenario: Every lesson content shows a Python or Java equivalent before the Ruby form
    Given any lesson in the curriculum
    When the lesson content loads
    Then a Python or Java code example appears before the Ruby syntax example
    And the explanation focuses on what is specifically different in Ruby

  @skip
  Scenario: Lesson 1 shows a Python method definition before the Ruby equivalent
    Given Lesson 1 "Syntax Differences" is available
    When the lesson content loads
    Then a Python function definition example is shown
    And the Ruby equivalent using "def" and "end" is shown after it
    And the explanation notes the specific differences: implicit return, end keyword, string interpolation

  # ---- Does Not Cover Section (AC-06-02) ----

  @skip
  Scenario: Every lesson preview includes a "What this does NOT cover" section
    Given any lesson in the curriculum
    When the lesson preview screen loads
    Then a "What this does NOT cover" section is present
    And that section lists at least one foundational concept that is not included

  @skip
  Scenario: The "does not cover" section for Lesson 1 lists variables and OOP as excluded
    Given Lesson 1 "Syntax Differences" is available
    When the lesson preview screen loads
    Then the "What this does NOT cover" section lists concepts such as "what a variable is"
    And it lists concepts such as "what OOP is"

  # ---- No Beginner Scaffolding (AC-06-03) ----

  @skip
  Scenario: No exercise prompt explains what a variable, loop, or basic OOP concept is
    Given any exercise across all 25 lessons
    When the exercise prompt renders
    Then the prompt does not contain the phrase "a variable is"
    And the prompt does not contain the phrase "OOP stands for"
    And the prompt assumes knowledge of the Python or Java equivalent concept

  # ---- Valid Code Examples (AC-06-04, AC-06-05) ----

  @skip
  Scenario: All Ruby code examples in exercise prompts are syntactically valid
    Given any exercise across all 25 lessons
    When the exercise content is inspected
    Then the Ruby code example is valid Ruby syntax
    And the Ruby code could be executed without a parse error

  @skip
  Scenario: All Python or Java code examples in exercise prompts are syntactically valid
    Given any exercise across all 25 lessons
    When the exercise content is inspected
    Then the Python or Java code example is valid syntax for that language
    And the comparison code could be executed without a parse error

  # ---- Lesson Metadata Completeness ----

  @skip
  Scenario: Every lesson has complete metadata including topics covered and not covered
    Given any lesson in the curriculum
    When the lesson metadata is loaded
    Then the lesson has a title
    And the lesson has a module assignment
    And the lesson has a duration estimate
    And the lesson has a list of topics covered
    And the lesson has a list of topics not covered
    And the lesson has at least one exercise

  # ---- Error and Edge Cases ----

  @skip
  Scenario: Lesson content loads correctly for all 25 lessons
    Given each of the 25 lessons in the curriculum
    When the lesson content is requested
    Then the lesson loads without error
    And the comparison format is present in each lesson

  # ---- Property Scenarios ----

  @property @skip
  Scenario: Every lesson across the entire curriculum follows the comparison format
    Given the full set of 25 lessons
    Then each lesson contains a Python or Java example before the Ruby example
    And each lesson has a "does not cover" section with at least one item
    And no lesson uses the word "variable" or "OOP" as a teaching concept in exercise prompts
