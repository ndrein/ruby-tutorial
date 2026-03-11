require "rails_helper"

# Test Budget: 4 behaviors x 2 = 8 max unit tests (using 7)
# B1: :locked when prerequisites not met
# B2: :mastered when all exercises sm2_interval >= 30
# B3: :in_review when all exercises sm2_interval 3-29
# B4: :available when prerequisites met and sm2_interval 1-2; :new when no reviews at all

RSpec.describe LessonStatusProjector do
  let!(:user) do
    User.find_or_create_by!(email: "projector_test@example.com") do |u|
      u.password = "password123"
      u.experience_level = "expert"
      u.timezone = "UTC"
    end
  end

  let!(:mod) do
    CourseModule.find_or_create_by!(position: 1) do |m|
      m.title = "Projector Test Module"
    end
  end

  let!(:prereq_lesson) do
    Lesson.find_or_create_by!(module_id: mod.id, position_in_module: 1) do |l|
      l.title = "Prereq"
      l.content_body = "Content."
      l.python_equivalent = "py."
      l.java_equivalent = "java."
      l.estimated_minutes = 2
      l.prerequisite_ids = []
    end
  end

  let!(:prereq_exercise) do
    Exercise.find_or_create_by!(lesson_id: prereq_lesson.id, position: 1) do |e|
      e.exercise_type = "fill_in_blank"
      e.prompt = "Prereq prompt"
      e.correct_answer = "x"
      e.accepted_synonyms = []
      e.explanation = "Explanation."
      e.options = []
    end
  end

  let!(:lesson_with_prereq) do
    Lesson.find_or_create_by!(module_id: mod.id, position_in_module: 2) do |l|
      l.title = "Locked Candidate"
      l.content_body = "Content."
      l.python_equivalent = "py."
      l.java_equivalent = "java."
      l.estimated_minutes = 3
      l.prerequisite_ids = [] # will set after prereq_lesson created
    end
  end

  let!(:lesson_no_prereq) do
    Lesson.find_or_create_by!(module_id: mod.id, position_in_module: 3) do |l|
      l.title = "Open Lesson"
      l.content_body = "Content."
      l.python_equivalent = "py."
      l.java_equivalent = "java."
      l.estimated_minutes = 4
      l.prerequisite_ids = []
    end
  end

  let!(:exercise_a) do
    Exercise.find_or_create_by!(lesson_id: lesson_no_prereq.id, position: 1) do |e|
      e.exercise_type = "fill_in_blank"
      e.prompt = "Prompt A"
      e.correct_answer = "a"
      e.accepted_synonyms = []
      e.explanation = "Explanation A."
      e.options = []
    end
  end

  let!(:exercise_b) do
    Exercise.find_or_create_by!(lesson_id: lesson_no_prereq.id, position: 2) do |e|
      e.exercise_type = "multiple_choice"
      e.prompt = "Prompt B"
      e.correct_answer = "b"
      e.accepted_synonyms = []
      e.explanation = "Explanation B."
      e.options = ["a", "b", "c", "d"]
    end
  end

  def create_review(user:, exercise:, interval:)
    Review.find_or_create_by!(user: user, exercise: exercise) do |r|
      r.next_review_date = Date.current + interval
      r.answer_result = "correct"
      r.quality_score = 4
      r.sm2_interval = interval
      r.sm2_ease_factor = 2.5
      r.repetitions = 2
    end
  end

  describe ".project" do
    # B1: :locked when prerequisites not met
    it "returns :locked when prerequisite lessons have no review records" do
      lesson_with_prereq.update!(prerequisite_ids: [prereq_lesson.id])

      status = LessonStatusProjector.project(lesson_with_prereq, user)

      expect(status).to eq(:locked)
    end

    # B2: :mastered when all exercises sm2_interval >= 30
    it "returns :mastered when all exercises have sm2_interval >= 30" do
      create_review(user: user, exercise: exercise_a, interval: 30)
      create_review(user: user, exercise: exercise_b, interval: 45)

      status = LessonStatusProjector.project(lesson_no_prereq, user)

      expect(status).to eq(:mastered)
    end

    # B2 variant: boundary — interval exactly 30 is mastered
    it "returns :mastered at sm2_interval boundary of 30" do
      create_review(user: user, exercise: exercise_a, interval: 30)
      create_review(user: user, exercise: exercise_b, interval: 30)

      status = LessonStatusProjector.project(lesson_no_prereq, user)

      expect(status).to eq(:mastered)
    end

    # B3: :in_review when all exercises sm2_interval 3-29
    it "returns :in_review when all exercises have sm2_interval between 3 and 29" do
      create_review(user: user, exercise: exercise_a, interval: 7)
      create_review(user: user, exercise: exercise_b, interval: 14)

      status = LessonStatusProjector.project(lesson_no_prereq, user)

      expect(status).to eq(:in_review)
    end

    # B3 variant: highest status drives status — one mastered, one in_review → in_review
    it "returns :in_review when some exercises are in review range and none below threshold" do
      create_review(user: user, exercise: exercise_a, interval: 3)
      create_review(user: user, exercise: exercise_b, interval: 29)

      status = LessonStatusProjector.project(lesson_no_prereq, user)

      expect(status).to eq(:in_review)
    end

    # B4: :new when prerequisites met and no review records
    it "returns :new when prerequisites are met and no reviews exist" do
      status = LessonStatusProjector.project(lesson_no_prereq, user)

      expect(status).to eq(:new)
    end

    # B4 variant: :available when some exercises reviewed with sm2_interval 1-2
    it "returns :available when all exercises reviewed but sm2_interval is 1 or 2" do
      create_review(user: user, exercise: exercise_a, interval: 1)
      create_review(user: user, exercise: exercise_b, interval: 2)

      status = LessonStatusProjector.project(lesson_no_prereq, user)

      expect(status).to eq(:available)
    end
  end
end
