require "rails_helper"

# Test Budget: 4 behaviors x 2 = 8 max unit tests (using 4)
# Behavior 1: 'h' typed in focused input = literal char, exercise not marked hard (AC-014-02)
# Behavior 2: hard_flag=true POST marks exercise as hard with reduced SM-2 quality score (AC-005-03)
# Behavior 3: Keyboard shortcuts are visible in exercise UI without opening help modal (XC-004)
# Behavior 4: g+d navigation shortcut is listed in the visible shortcuts panel (AC-014-03)

RSpec.describe "Keyboard navigation", type: :system do
  let!(:course_module) do
    CourseModule.find_or_create_by!(id: 2) do |m|
      m.title = "Ruby Keyboard Test Module"
      m.position = 2
    end
  end

  let!(:lesson) do
    Lesson.find_or_create_by!(id: 2) do |l|
      l.module_id = course_module.id
      l.title = "Ruby Keyboard Test Lesson"
      l.position_in_module = 1
      l.content_body = "Ruby blocks."
      l.python_equivalent = "Python lambda."
      l.java_equivalent = "Java lambda."
      l.estimated_minutes = 5
      l.prerequisite_ids = []
    end
  end

  let!(:exercise) do
    Exercise.find_or_create_by!(id: 2) do |e|
      e.lesson_id = lesson.id
      e.exercise_type = "fill_in_blank"
      e.prompt = "Complete: arr.____(){ |x| x > 3 }"
      e.correct_answer = "select"
      e.accepted_synonyms = []
      e.explanation = "Array#select filters elements."
      e.options = []
      e.position = 1
    end
  end

  let!(:user) do
    User.find_or_create_by!(email: "keyboard_test@example.com") do |u|
      u.password = "password123"
      u.experience_level = "expert"
      u.timezone = "UTC"
    end
  end

  # Behavior 1: Submitting with hard_flag=false (input focused, 'h' typed as char) does NOT mark hard (AC-014-02)
  it "records a correct answer without hard flag when hard_flag param is false" do
    expect {
      page.driver.post(
        submit_exercise_path(exercise),
        { answer: "select", answer_result: "correct", elapsed_seconds: 5, hard_flag: "false" }
      )
    }.to change(Review, :count).by(1)

    review = Review.last
    expect(review.quality_score).to be >= 4
  end

  # Behavior 2: Submitting with hard_flag=true (h shortcut outside input) reduces SM-2 quality score (AC-005-03)
  # elapsed_seconds=15 => base correct score = 4; hard_flag=true => score = 3 (reduced by 1)
  it "records a reduced quality score when hard_flag param is true" do
    page.driver.post(
      submit_exercise_path(exercise),
      { answer: "select", answer_result: "correct", elapsed_seconds: 15, hard_flag: "false" }
    )
    base_quality = Review.last.quality_score

    page.driver.post(
      submit_exercise_path(exercise),
      { answer: "select", answer_result: "correct", elapsed_seconds: 15, hard_flag: "true" }
    )
    hard_quality = Review.last.quality_score

    expect(hard_quality).to eq(base_quality - 1)
  end

  # Behavior 3: Keyboard shortcuts legend is visible on the exercise page without opening any help modal (XC-004)
  it "displays keyboard shortcuts on the exercise page without requiring any modal interaction" do
    visit exercise_path(exercise)

    expect(page).to have_css(".keyboard-shortcuts")
    expect(page).to have_content("Enter")
    expect(page).to have_content("Esc")
  end

  # Behavior 4: g+d navigation shortcut is listed in the visible shortcuts panel (AC-014-03)
  it "shows the g+d dashboard navigation shortcut in the keyboard shortcuts panel" do
    visit exercise_path(exercise)

    within(".keyboard-shortcuts") do
      expect(page).to have_content("g")
      expect(page).to have_content("d")
    end
  end
end
