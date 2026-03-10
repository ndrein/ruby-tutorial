require "rails_helper"

RSpec.describe Review, type: :model do
  # Test Budget: 2 behaviors x 2 = 4 max unit tests (using 2)
  # Behavior 1: sm2_ease_factor DB CHECK constraint [1.30, 2.50] enforced
  # Behavior 2: sm2_interval DB CHECK constraint >= 1 enforced

  let(:user) do
    User.create!(
      email: "test@example.com",
      experience_level: "beginner",
      password_digest: BCrypt::Password.create("password123"),
      streak_count: 0,
      email_opted_in: false,
      email_delivery_hour: 8,
      timezone: "UTC"
    )
  end

  let(:mod) { CourseModule.create!(id: 1, title: "Ruby Basics", position: 1) }

  let(:lesson) do
    Lesson.create!(
      id: 1,
      module_id: mod.id,
      title: "Variables",
      position_in_module: 1,
      content_body: "Content",
      python_equivalent: "x = 1",
      java_equivalent: "int x = 1;",
      estimated_minutes: 3,
      prerequisite_ids: []
    )
  end

  let(:exercise) do
    Exercise.create!(
      id: 1,
      lesson_id: lesson.id,
      exercise_type: "fill_in_blank",
      prompt: "What is x?",
      correct_answer: "variable",
      accepted_synonyms: [],
      explanation: "x is a variable",
      options: [],
      position: 1
    )
  end

  let(:valid_review_attrs) do
    {
      user_id: user.id,
      exercise_id: exercise.id,
      sm2_interval: 1,
      sm2_ease_factor: 2.50,
      repetitions: 0,
      next_review_date: Date.today,
      answer_result: "correct",
      quality_score: 5
    }
  end

  describe "DB CHECK constraint enforcement" do
    it "rejects sm2_ease_factor outside [1.30, 2.50] range" do
      review = Review.new(valid_review_attrs.merge(sm2_ease_factor: 0.5))
      expect { review.save!(validate: false) }.to raise_error(ActiveRecord::StatementInvalid)
    end

    it "rejects sm2_interval less than 1" do
      review = Review.new(valid_review_attrs.merge(sm2_interval: 0))
      expect { review.save!(validate: false) }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end
end
