require "rails_helper"

# Test Budget: 3 behaviors x 2 = 6 max tests (using 3)
# Behavior 1: Experience step shows one question with two keyboard-selectable options (AC-001-02)
# Behavior 2: Selecting 'Yes' routes to Lesson 1 and stores experience_level='expert' (AC-001-03)
# Behavior 3: Full flow: register -> onboarding -> lesson 1 (AC-001-05)

RSpec.describe "Onboarding flow", type: :system do
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

  # Behavior 1: Experience step shows exactly one question with two options (AC-001-02)
  it "renders the experience step with exactly one question and two keyboard-selectable options" do
    visit onboarding_experience_path

    expect(page).to have_css("form")
    # One question visible
    expect(page).to have_css("[data-question]", count: 1)
    # Two radio or button options
    option_count = all("input[type=radio]").count + all("button[type=submit]").count
    expect(option_count).to eq(2)
  end

  # Behavior 2: Selecting 'Yes' routes to Lesson 1 and stores experience_level='expert' (AC-001-03)
  it "stores experience_level=expert and routes to Lesson 1 when user selects Yes" do
    user = User.create!(email: "onboarding_test@example.com", password: "secret123",
                        experience_level: "beginner", timezone: "UTC")

    # Simulate session by posting directly (system test equivalent)
    page.driver.post(onboarding_experience_path,
                     { experience_level: "expert", user_id: user.id })

    user.reload
    expect(user.experience_level).to eq("expert")
    expect(page.driver.response.location).to include("/lessons/1")
  end

  # Behavior 3: Full registration -> onboarding -> lesson 1 flow completes (AC-001-05)
  it "completes the full onboarding flow from registration to Lesson 1" do
    visit new_user_path

    fill_in "user[email]", with: "flow_test@example.com"
    click_button "Continue"

    expect(page.current_path).to eq(onboarding_experience_path)

    # Select 'Yes' option
    find("input[type=radio][value='expert']").click
    click_button "Continue"

    expect(page.current_path).to eq(lesson_path(1))
    expect(page).to have_content("Ruby Blocks")

    user = User.find_by(email: "flow_test@example.com")
    expect(user.experience_level).to eq("expert")
  end
end
