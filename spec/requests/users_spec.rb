require "rails_helper"

# Test Budget: 4 behaviors x 2 = 8 max tests (using 4)
# Behavior 1: Registration form renders with only email field (AC-001-01)
# Behavior 2: New user registration redirects to onboarding experience step (AC-001-02)
# Behavior 3: Duplicate email shows friendly error without stack trace (AC-001-04)
# Behavior 4: User record created with correct defaults on registration

RSpec.describe "Users", type: :request do
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

  # Behavior 1: Registration form has exactly one required field (email only) (AC-001-01)
  describe "GET /users/new" do
    it "renders a form with exactly one visible required field: email, and no password, name, or phone fields" do
      get new_user_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('type="email"')
      expect(response.body).not_to include('type="password"')
      expect(response.body).not_to match(/name.*field|phone.*field/i)
      expect(response.body).not_to include('name="user[name]"')
      expect(response.body).not_to include('name="user[phone]"')
    end
  end

  # Behavior 2: New user registration redirects to onboarding (AC-001-02)
  describe "POST /users" do
    it "creates a user and redirects to the onboarding experience step" do
      expect {
        post users_path, params: { user: { email: "newuser@example.com" } }
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(onboarding_experience_path)
    end
  end

  # Behavior 3: Duplicate email shows friendly error without stack trace (AC-001-04)
  describe "POST /users with duplicate email" do
    before do
      User.create!(email: "existing@example.com", password: "secret123",
                   experience_level: "expert", timezone: "UTC")
    end

    it "shows a human-readable error message and a login link without any database error codes" do
      post users_path, params: { user: { email: "existing@example.com" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("This email is already registered")
      expect(response.body).to include("login")
      expect(response.body).not_to include("PG::")
      expect(response.body).not_to include("UniqueViolation")
      expect(response.body).not_to include("ERROR:")
    end
  end
end
