require "rails_helper"

# Test Budget: 5 behaviors x 2 = 10 max tests (using 5 system tests)
# Behavior 1: All 5 modules listed with 'X of 5 lessons' fraction (AC-018-01)
# Behavior 2: Locked lesson card shows prerequisite status and unlock estimate (AC-019-01, AC-017-02)
# Behavior 3: Available lesson card shows 'Start now' and 'Queue for next session' actions (AC-017-01)
# Behavior 4: Lesson card shows number, title, module name, estimated time, exercise type (AC-017-01)
# Behavior 5: Lesson without met prerequisites does not show 'Start now' action (AC-017-02)

RSpec.describe "Curriculum view", type: :system do
  let!(:user) do
    User.find_or_create_by!(email: "marcus@example.com") do |u|
      u.password = "password123"
      u.experience_level = "expert"
      u.timezone = "UTC"
    end
  end

  let!(:mod1) do
    CourseModule.find_or_create_by!(position: 1) do |m|
      m.title = "Ruby Fundamentals"
    end
  end

  let!(:mod2) do
    CourseModule.find_or_create_by!(position: 2) do |m|
      m.title = "Collections"
    end
  end

  let!(:mod3) do
    CourseModule.find_or_create_by!(position: 3) do |m|
      m.title = "OOP"
    end
  end

  let!(:mod4) do
    CourseModule.find_or_create_by!(position: 4) do |m|
      m.title = "Blocks and Procs"
    end
  end

  let!(:mod5) do
    CourseModule.find_or_create_by!(position: 5) do |m|
      m.title = "Metaprogramming"
    end
  end

  # Lessons for mod1 — 5 lessons
  let!(:lesson1) do
    Lesson.find_or_create_by!(module_id: mod1.id, position_in_module: 1) do |l|
      l.title = "Variables and Types"
      l.content_body = "Variables in Ruby."
      l.python_equivalent = "Python vars."
      l.java_equivalent = "Java vars."
      l.estimated_minutes = 3
      l.prerequisite_ids = []
    end
  end

  let!(:lesson2) do
    Lesson.find_or_create_by!(module_id: mod1.id, position_in_module: 2) do |l|
      l.title = "Control Flow"
      l.content_body = "If/else in Ruby."
      l.python_equivalent = "Python if."
      l.java_equivalent = "Java if."
      l.estimated_minutes = 4
      l.prerequisite_ids = []  # will be set to [lesson1.id] after creation
    end
  end

  let!(:exercise1) do
    Exercise.find_or_create_by!(lesson_id: lesson1.id, position: 1) do |e|
      e.exercise_type = "fill_in_blank"
      e.prompt = "Fill in: x = ___"
      e.correct_answer = "42"
      e.accepted_synonyms = []
      e.explanation = "Variable assignment."
      e.options = []
    end
  end

  let!(:exercise2) do
    Exercise.find_or_create_by!(lesson_id: lesson2.id, position: 1) do |e|
      e.exercise_type = "multiple_choice"
      e.prompt = "Which keyword starts a loop?"
      e.correct_answer = "while"
      e.accepted_synonyms = []
      e.explanation = "While loop."
      e.options = ["while", "for", "loop", "each"]
    end
  end

  before do
    allow(User).to receive(:first).and_return(user)
  end

  # Behavior 1: All 5 modules listed with fraction (AC-018-01)
  it "lists all 5 modules with their lesson fraction" do
    visit curriculum_index_path

    expect(page).to have_content("Ruby Fundamentals")
    expect(page).to have_content("Collections")
    expect(page).to have_content("OOP")
    expect(page).to have_content("Blocks and Procs")
    expect(page).to have_content("Metaprogramming")
    # mod1 has 2 lessons, shows fraction like '2 of 5 lessons'
    expect(page).to have_content("of 5 lessons")
  end

  # Behavior 3: Available lesson shows 'Start now' and 'Queue for next session' (AC-017-01)
  it "shows Start now and Queue for next session actions for an available lesson" do
    visit curriculum_index_path

    # lesson1 has no prerequisites and no reviews → available/new status
    within("[data-lesson-id='#{lesson1.id}']") do
      expect(page).to have_content("Start now")
      expect(page).to have_content("Queue for next session")
    end
  end

  # Behavior 4: Lesson card shows number, title, module name, estimated time, exercise type (AC-017-01)
  it "shows lesson details on an available lesson card" do
    visit curriculum_index_path

    within("[data-lesson-id='#{lesson1.id}']") do
      expect(page).to have_content("Variables and Types")
      expect(page).to have_content("Ruby Fundamentals")
      expect(page).to have_content("3")          # estimated_minutes
      expect(page).to have_content("fill_in_blank")
    end
  end

  # Behavior 5: Locked lesson does not show 'Start now' action (AC-017-02)
  it "does not show Start now for a locked lesson" do
    lesson2.update!(prerequisite_ids: [lesson1.id])

    visit curriculum_index_path

    # lesson2 has lesson1 as prerequisite, user has no reviews → locked
    within("[data-lesson-id='#{lesson2.id}']") do
      expect(page).not_to have_content("Start now")
    end
  end

  # Behavior 2: Locked lesson shows prerequisite status and unlock estimate (AC-019-01)
  it "shows prerequisite completion status and estimated unlock sessions for a locked lesson" do
    lesson2.update!(prerequisite_ids: [lesson1.id])

    visit curriculum_index_path

    within("[data-lesson-id='#{lesson2.id}']") do
      expect(page).to have_content("Variables and Types")  # prerequisite lesson title
      expect(page).to have_content("sessions to unlock")
    end
  end
end
