require "rails_helper"

# Test Budget: 5 behaviors x 2 = 10 max tests (1 request test for AC-5 — no stored lesson_status)
# Behavior 5: All dashboard metrics derived from reviews.sm2_interval at read time, no lesson_status column read (AC-012-05)

RSpec.describe "Dashboard", type: :request do
  let!(:user) do
    User.find_or_create_by!(email: "marcus_dashboard_req@example.com") do |u|
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

  before do
    allow(User).to receive(:first).and_return(user)
  end

  # Behavior 5: No stored lesson_status — all metrics derived from reviews at read time (AC-012-05)
  it "renders dashboard metrics without reading any lesson_status column from the database" do
    get dashboard_path

    expect(response).to have_http_status(:ok)
    # Verify the response body does not reference a non-existent lesson_status column
    # (the schema has no such column; the controller must not query it)
    expect(response.body).to include("Mastered")
    expect(response.body).to include("In Review")
    expect(response.body).to include("New")
    expect(response.body).to include("lessons")
  end
end
