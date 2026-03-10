require "rails_helper"

RSpec.describe "Exercises", type: :request do
  # Test Budget: 5 behaviors x 2 = 10 max tests (using 5 request + 3 model = 8)
  # Behavior 1: correct answer creates review with sm2_interval=1 and response contains 'Correct'
  # Behavior 2: incorrect answer creates review with sm2_interval=1 and shows correct answer
  # Behavior 3: accepted_synonym treated as correct
  # Behavior 4: SM-2 state persisted matches SM2Engine output (atomic transaction)
  # Behavior 5: quality_score=5 for correct+fast+no_hard_flag, quality_score=3 with hard_flag

  let!(:course_module) { CourseModule.find_or_create_by!(id: 1) { |m| m.title = "Ruby Fundamentals"; m.position = 1 } }

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
      e.accepted_synonyms = [ "Array#select" ]
      e.explanation = "Array#select returns elements for which the block returns true."
      e.options = []
      e.position = 1
    end
  end

  let!(:user) do
    User.find_or_create_by!(email: "test@example.com") do |u|
      u.password = "password123"
      u.experience_level = "expert"
      u.timezone = "UTC"
    end
  end

  describe "POST /exercises/:id/submit" do
    context "with a correct answer" do
      it "creates a review row with sm2_interval=1 and responds with Correct" do
        expect {
          post submit_exercise_path(exercise), params: {
            answer: "select",
            elapsed_seconds: 8,
            hard_flag: "false"
          }
        }.to change(Review, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Correct")

        review = Review.last
        expect(review.sm2_interval).to eq(1)
        expect(review.repetitions).to eq(1)
        expect(review.next_review_date).to eq(Date.today + 1)
        expect(review.answer_result).to eq("correct")
      end
    end

    context "with an incorrect answer" do
      it "creates a review row with sm2_interval=1 and shows the correct answer and explanation" do
        expect {
          post submit_exercise_path(exercise), params: {
            answer: "map",
            elapsed_seconds: 12,
            hard_flag: "false"
          }
        }.to change(Review, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Incorrect")
        expect(response.body).to include(exercise.correct_answer)
        expect(response.body).to include(exercise.explanation)

        review = Review.last
        expect(review.sm2_interval).to eq(1)
        expect(review.next_review_date).to eq(Date.today + 1)
        expect(review.answer_result).to eq("incorrect")
      end
    end

    context "with an accepted synonym" do
      it "treats the answer as correct" do
        post submit_exercise_path(exercise), params: {
          answer: "Array#select",
          elapsed_seconds: 5,
          hard_flag: "false"
        }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Correct")

        review = Review.last
        expect(review.answer_result).to eq("correct")
      end
    end

    context "with quality_score calculation" do
      it "sets quality_score=5 for correct answer under 10 seconds without hard_flag" do
        post submit_exercise_path(exercise), params: {
          answer: "select",
          elapsed_seconds: 8,
          hard_flag: "false"
        }

        review = Review.last
        expect(review.quality_score).to eq(5)
      end

      it "sets quality_score=3 for correct answer with hard_flag=true" do
        post submit_exercise_path(exercise), params: {
          answer: "select",
          elapsed_seconds: 8,
          hard_flag: "true"
        }

        review = Review.last
        expect(review.quality_score).to eq(3)
      end
    end
  end
end
