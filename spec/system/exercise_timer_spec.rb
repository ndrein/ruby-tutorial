require "rails_helper"

# Test Budget: 4 behaviors x 2 = 8 max unit tests (using 4)
# Behavior 1: Timer "0:30" is rendered in the exercise page HTML (AC-010-01)
# Behavior 2: Timeout POST creates review with answer_result=timeout and sm2_interval=1 (AC-000-06, AC-010-02)
# Behavior 3: Timeout POST creates review with quality_score=0 (AC-010-02)
# Behavior 4: Answer input has autofocus attribute on exercise page (AC-000-03, AC-005-01)

RSpec.describe "Exercise timer", type: :system do
  let!(:course_module) do
    CourseModule.find_or_create_by!(id: 1) do |m|
      m.title = "Ruby Fundamentals"
      m.position = 1
    end
  end

  let!(:lesson) do
    Lesson.find_or_create_by!(id: 1) do |l|
      l.module_id = course_module.id
      l.title = "Ruby Blocks"
      l.position_in_module = 1
      l.content_body = "Ruby blocks are anonymous functions."
      l.python_equivalent = "Equivalent to Python lambda."
      l.java_equivalent = "Similar to Java 8+ lambda expressions."
      l.estimated_minutes = 5
      l.prerequisite_ids = []
    end
  end

  let!(:exercise) do
    Exercise.find_or_create_by!(id: 1) do |e|
      e.lesson_id = lesson.id
      e.exercise_type = "fill_in_blank"
      e.prompt = "Complete: arr.____(){ |x| x > 3 }"
      e.correct_answer = "select"
      e.accepted_synonyms = []
      e.explanation = "Array#select returns elements for which the block returns true."
      e.options = []
      e.position = 1
    end
  end

  let!(:user) do
    User.find_or_create_by!(email: "timer_test@example.com") do |u|
      u.password = "password123"
      u.experience_level = "expert"
      u.timezone = "UTC"
    end
  end

  # Behavior 1: Timer "0:30" visible in primary viewport (AC-010-01)
  it "renders a timer displaying 0:30 on the exercise page" do
    visit exercise_path(exercise)

    expect(page).to have_content("0:30")
  end

  # Behavior 2 & 3: Timeout POST creates review with correct SM-2 data and quality_score=0 (AC-000-06, AC-010-02)
  it "creates a review with answer_result=timeout, sm2_interval=1, and quality_score=0 when timeout is submitted" do
    expect {
      page.driver.post(
        submit_exercise_path(exercise),
        { answer: "", answer_result: "timeout", elapsed_seconds: 30, hard_flag: "false" }
      )
    }.to change(Review, :count).by(1)

    review = Review.last
    expect(review.answer_result).to eq("timeout")
    expect(review.sm2_interval).to eq(1)
    expect(review.quality_score).to eq(0)
  end

  # Behavior 4: Answer input autofocused (AC-000-03, AC-005-01)
  it "renders the answer input with autofocus attribute" do
    visit exercise_path(exercise)

    expect(page).to have_css("input#answer[autofocus]")
  end
end
