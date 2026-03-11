require "rails_helper"

# Test Budget: 3 behaviors x 2 = 6 max unit tests (using 5 system tests)
# Behavior 1: Focus ring CSS applied globally — no outline:none overrides present (AC-015-01, AC-015-02)
# Behavior 2: Keyboard shortcuts visible on all primary screens without modal (XC-004, FR-6.5)
# Behavior 3: Curriculum screen shows keyboard shortcuts without modal (XC-004)

RSpec.describe "Accessibility and keyboard shortcut UI", type: :system do
  let!(:user) do
    User.find_or_create_by!(email: "accessibility_test@example.com") do |u|
      u.password = "password123"
      u.experience_level = "expert"
      u.timezone = "UTC"
    end
  end

  let!(:course_module) do
    CourseModule.find_or_create_by!(position: 1) do |m|
      m.title = "Ruby Fundamentals"
    end
  end

  let!(:lesson) do
    Lesson.find_or_create_by!(module_id: course_module.id, position_in_module: 1) do |l|
      l.title = "Variables and Types"
      l.content_body = "Variables in Ruby."
      l.python_equivalent = "Python vars."
      l.java_equivalent = "Java vars."
      l.estimated_minutes = 3
      l.prerequisite_ids = []
    end
  end

  let!(:exercise) do
    Exercise.find_or_create_by!(lesson_id: lesson.id, position: 1) do |e|
      e.exercise_type = "fill_in_blank"
      e.prompt = "Fill in: x = ___"
      e.correct_answer = "42"
      e.accepted_synonyms = []
      e.explanation = "Variable assignment."
      e.options = []
    end
  end

  before do
    allow(User).to receive(:first).and_return(user)
  end

  # Behavior 1: Global focus ring CSS — application.css must define *:focus outline, no outline:none override (AC-015-01, AC-015-02)
  it "applies a focus ring style in the global stylesheet without outline:none overrides" do
    css_path = Rails.root.join("app/assets/stylesheets/application.css")
    css_content = File.read(css_path)

    expect(css_content).to include("outline")
    expect(css_content).not_to match(/outline\s*:\s*none/)
    expect(css_content).not_to match(/outline\s*:\s*0/)
  end

  # Behavior 2: Keyboard shortcuts visible on session and exercise screens without modal (XC-004)
  it "shows keyboard shortcuts on the session start screen without any modal interaction" do
    visit new_session_path

    expect(page).to have_css(".keyboard-shortcuts")
    expect(page).not_to have_css("[data-modal]", visible: true)
  end

  it "shows keyboard shortcuts on the exercise screen without any modal interaction" do
    visit exercise_path(exercise)

    expect(page).to have_css(".keyboard-shortcuts")
    expect(page).not_to have_css("[data-modal]", visible: true)
  end

  it "shows keyboard shortcuts on the dashboard screen without any modal interaction" do
    visit dashboard_path

    expect(page).to have_css(".keyboard-shortcuts")
    expect(page).not_to have_css("[data-modal]", visible: true)
  end

  # Behavior 3: Curriculum screen shows keyboard shortcuts without modal (XC-004)
  it "shows keyboard shortcuts on the curriculum screen without any modal interaction" do
    visit curriculum_index_path

    expect(page).to have_css(".keyboard-shortcuts")
    expect(page).not_to have_css("[data-modal]", visible: true)
  end
end
