require "rails_helper"

# Test Budget: 4 distinct behaviors x 2 = 8 max unit tests
# Behavior 1: Includes due/overdue exercises, excludes future ones, orders by next_review_date ASC
# Behavior 2: Truncates to 20 exercises when more than 20 are due
# Behavior 3: Idempotent upsert - second run does not raise, exactly one row persisted
# Behavior 4: No due exercises returns empty exercise_ids

RSpec.describe QueueBuilder do
  let!(:user) do
    User.create!(
      email: "queue_builder_test@example.com",
      password: "password123",
      experience_level: "expert",
      timezone: "UTC"
    )
  end

  let(:today) { Date.new(2026, 3, 11) }

  # A shared module+lesson pair reused across all tests in this describe block.
  # Uses positions 1..5 from CourseModule and position_in_module up to 5 per lesson.
  # For the 25-exercise test we create multiple lessons within the same module.
  let!(:course_module) do
    CourseModule.create!(title: "QueueBuilder Test Module", position: 3)
  end

  # Creates a lesson inside course_module with a given position_in_module (1-5)
  def create_lesson(position_in_module:)
    Lesson.create!(
      module_id: course_module.id,
      title: "Lesson pos#{position_in_module} #{SecureRandom.hex(2)}",
      position_in_module: position_in_module,
      content_body: "body",
      java_equivalent: "java",
      python_equivalent: "python",
      estimated_minutes: 5
    )
  end

  # Creates an exercise within a lesson at a given position (1-5)
  def create_exercise(lesson:, position: 1)
    Exercise.create!(
      lesson_id: lesson.id,
      exercise_type: "fill_in_blank",
      prompt: "prompt #{SecureRandom.hex(4)}",
      correct_answer: "answer",
      explanation: "explanation",
      position: position
    )
  end

  def create_review(user:, exercise:, next_review_date:)
    Review.create!(
      user_id: user.id,
      exercise_id: exercise.id,
      next_review_date: next_review_date,
      answer_result: "correct",
      quality_score: 4,
      repetitions: 1,
      sm2_interval: 1,
      sm2_ease_factor: 2.5
    )
  end

  # Behavior 1: Filters due/overdue exercises, excludes future, orders ASC
  describe ".build" do
    context "when exercises have mixed due dates" do
      it "includes due and overdue exercises, excludes future, orders oldest-due first" do
        lesson = create_lesson(position_in_module: 1)
        exercise_a = create_exercise(lesson: lesson, position: 1)
        exercise_b = create_exercise(lesson: lesson, position: 2)
        exercise_c = create_exercise(lesson: lesson, position: 3)

        create_review(user: user, exercise: exercise_a, next_review_date: today)
        create_review(user: user, exercise: exercise_b, next_review_date: today - 1)
        create_review(user: user, exercise: exercise_c, next_review_date: today + 1)

        queue = QueueBuilder.build(user_id: user.id, date: today)

        expect(queue.exercise_ids).to include(exercise_a.id)
        expect(queue.exercise_ids).to include(exercise_b.id)
        expect(queue.exercise_ids).not_to include(exercise_c.id)

        # Oldest-due first: exercise_b (yesterday) before exercise_a (today)
        b_index = queue.exercise_ids.index(exercise_b.id)
        a_index = queue.exercise_ids.index(exercise_a.id)
        expect(b_index).to be < a_index
      end
    end

    # Behavior 2: Truncates at 20
    context "when 25 exercises are due today" do
      it "returns a queue with exactly 20 exercise_ids" do
        # 5 lessons x 5 exercises = 25 exercises
        exercises = (1..5).flat_map do |lesson_pos|
          lesson = create_lesson(position_in_module: lesson_pos)
          (1..5).map do |ex_pos|
            ex = create_exercise(lesson: lesson, position: ex_pos)
            create_review(user: user, exercise: ex, next_review_date: today)
            ex
          end
        end

        queue = QueueBuilder.build(user_id: user.id, date: today)

        expect(queue.exercise_ids.length).to eq(20)
      end
    end

    # Behavior 3: Idempotent upsert
    context "when QueueBuilder runs twice for the same user and date" do
      it "upserts without error and results in exactly one daily_queue row" do
        lesson = create_lesson(position_in_module: 1)
        exercise = create_exercise(lesson: lesson, position: 1)
        create_review(user: user, exercise: exercise, next_review_date: today)

        expect {
          QueueBuilder.build(user_id: user.id, date: today)
          QueueBuilder.build(user_id: user.id, date: today)
        }.not_to raise_error

        count = DailyQueue.where(user_id: user.id, queue_date: today).count
        expect(count).to eq(1)
      end
    end

    # Behavior 4: No due exercises
    context "when no exercises are due on the given date" do
      it "persists a daily_queue row with empty exercise_ids" do
        queue = QueueBuilder.build(user_id: user.id, date: today)

        expect(queue.exercise_ids).to eq([])
        expect(DailyQueue.where(user_id: user.id, queue_date: today).count).to eq(1)
      end
    end
  end
end
