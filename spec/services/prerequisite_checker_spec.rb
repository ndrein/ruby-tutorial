require "rails_helper"

# Test Budget: 2 behaviors x 2 = 4 max unit tests
# Behavior 1: All prerequisite lesson IDs have at least one review → met? returns true
# Behavior 2: Any prerequisite lesson ID with no review → met? returns false

RSpec.describe PrerequisiteChecker do
  let!(:user) do
    User.find_or_create_by!(email: "checker_test@example.com") do |u|
      u.password = "password123"
      u.experience_level = "expert"
      u.timezone = "UTC"
    end
  end

  let!(:mod) do
    CourseModule.find_or_create_by!(position: 1) do |m|
      m.title = "Test Module"
    end
  end

  let!(:prereq_lesson) do
    Lesson.find_or_create_by!(module_id: mod.id, position_in_module: 1) do |l|
      l.title = "Prereq Lesson"
      l.content_body = "Content."
      l.python_equivalent = "py."
      l.java_equivalent = "java."
      l.estimated_minutes = 3
      l.prerequisite_ids = []
    end
  end

  let!(:prereq_exercise) do
    Exercise.find_or_create_by!(lesson_id: prereq_lesson.id, position: 1) do |e|
      e.exercise_type = "fill_in_blank"
      e.prompt = "Fill in."
      e.correct_answer = "answer"
      e.accepted_synonyms = []
      e.explanation = "Explanation."
      e.options = []
    end
  end

  let!(:target_lesson) do
    Lesson.find_or_create_by!(module_id: mod.id, position_in_module: 2) do |l|
      l.title = "Target Lesson"
      l.content_body = "Content."
      l.python_equivalent = "py."
      l.java_equivalent = "java."
      l.estimated_minutes = 3
      l.prerequisite_ids = [prereq_lesson.id]
    end
  end

  describe ".met?" do
    # Behavior 1: all prerequisites have reviews → true
    it "returns true when all prerequisite lessons have at least one review for the user" do
      Review.find_or_create_by!(user: user, exercise: prereq_exercise) do |r|
        r.next_review_date = Date.current + 1
        r.answer_result = "correct"
        r.quality_score = 4
        r.sm2_interval = 1
        r.sm2_ease_factor = 2.5
        r.repetitions = 1
      end

      expect(PrerequisiteChecker.met?(target_lesson, user)).to be true
    end

    # Behavior 1 variant: no prerequisites → always met
    it "returns true when the lesson has no prerequisites" do
      no_prereq_lesson = Lesson.find_or_create_by!(module_id: mod.id, position_in_module: 3) do |l|
        l.title = "No Prereq Lesson"
        l.content_body = "Content."
        l.python_equivalent = "py."
        l.java_equivalent = "java."
        l.estimated_minutes = 2
        l.prerequisite_ids = []
      end

      expect(PrerequisiteChecker.met?(no_prereq_lesson, user)).to be true
    end

    # Behavior 2: prerequisite has no review → false
    it "returns false when a prerequisite lesson has no review for the user" do
      expect(PrerequisiteChecker.met?(target_lesson, user)).to be false
    end
  end
end
