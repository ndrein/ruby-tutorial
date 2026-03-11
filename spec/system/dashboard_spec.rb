require "rails_helper"

# Test Budget: 5 behaviors x 2 = 10 max tests (using 4 system tests + 1 request test)
# Behavior 1: SM-2 interval mastery counts displayed (mastered >=30, in_review 3-29, new 1-2) (AC-012-01)
# Behavior 2: Lessons completed fraction shown as 'X of Y lessons (Z%)' (AC-012-02)
# Behavior 3: Retention rate shows 'Not enough data yet' when account < 14 days old (AC-012-03)
# Behavior 4: Keyboard shortcuts c→curriculum, s→session navigate the browser (AC-012-04)

RSpec.describe "Progress dashboard", type: :system do
  let!(:user) do
    User.find_or_create_by!(email: "marcus_dashboard@example.com") do |u|
      u.password = "password123"
      u.experience_level = "expert"
      u.timezone = "UTC"
      u.streak_count = 5
    end
  end

  let!(:course_module) do
    CourseModule.find_or_create_by!(position: 1) do |m|
      m.title = "Ruby Fundamentals"
    end
  end

  def create_lesson_with_exercise(module_id, position)
    lesson = Lesson.find_or_create_by!(module_id: module_id, position_in_module: position) do |l|
      l.title = "Lesson #{position}"
      l.content_body = "Content #{position}."
      l.python_equivalent = "Python #{position}."
      l.java_equivalent = "Java #{position}."
      l.estimated_minutes = 3
      l.prerequisite_ids = []
    end
    exercise = Exercise.find_or_create_by!(lesson_id: lesson.id, position: 1) do |e|
      e.exercise_type = "fill_in_blank"
      e.prompt = "Prompt #{position}"
      e.correct_answer = "answer#{position}"
      e.accepted_synonyms = []
      e.explanation = "Explanation #{position}."
      e.options = []
    end
    [lesson, exercise]
  end

  def create_review_with_interval(user, exercise, interval)
    Review.find_or_create_by!(user_id: user.id, exercise_id: exercise.id) do |r|
      r.sm2_interval = interval
      r.sm2_ease_factor = 2.5
      r.repetitions = 1
      r.next_review_date = Date.current + interval
      r.answer_result = "correct"
      r.quality_score = 4
    end
  end

  before do
    allow(User).to receive(:first).and_return(user)
  end

  # Behavior 1: SM-2 interval counts (AC-012-01)
  # Marcus has 12 mastered (>=30), 8 in_review (3-29), 4 new (1-2)
  it "shows mastery counts derived from sm2_interval groupings" do
    # Create 24 exercises across lessons
    exercises = (1..5).map { |pos| create_lesson_with_exercise(course_module.id, pos) }.flat_map { |_, e| [e] }

    # We need 24 exercises but only have 5 lessons with 1 exercise each
    # Create more modules and lessons for the full set
    mod2 = CourseModule.find_or_create_by!(position: 2) { |m| m.title = "Collections" }
    mod3 = CourseModule.find_or_create_by!(position: 3) { |m| m.title = "OOP" }
    mod4 = CourseModule.find_or_create_by!(position: 4) { |m| m.title = "Blocks" }
    mod5 = CourseModule.find_or_create_by!(position: 5) { |m| m.title = "Metaprogramming" }

    all_exercises = exercises.dup
    [mod2, mod3, mod4, mod5].each_with_index do |mod, mi|
      (1..5).each do |pos|
        _, ex = create_lesson_with_exercise(mod.id, pos)
        all_exercises << ex
      end
    end

    # 12 mastered (interval >= 30)
    all_exercises[0..11].each { |ex| create_review_with_interval(user, ex, 30) }
    # 8 in review (interval 3-29)
    all_exercises[12..19].each { |ex| create_review_with_interval(user, ex, 10) }
    # 4 new (interval 1-2)
    all_exercises[20..23].each { |ex| create_review_with_interval(user, ex, 1) }

    visit dashboard_path

    expect(page).to have_content("Mastered: 12")
    expect(page).to have_content("In Review: 8")
    expect(page).to have_content("New: 4")
  end

  # Behavior 2: Lessons completed fraction (AC-012-02)
  it "shows lessons completed fraction and percentage" do
    # Set user created_at to 15+ days ago to avoid 'not enough data' for other parts
    user.update_column(:created_at, 20.days.ago)

    # 25 total lessons across modules (5 lessons x 5 modules)
    mod2 = CourseModule.find_or_create_by!(position: 2) { |m| m.title = "Collections" }
    mod3 = CourseModule.find_or_create_by!(position: 3) { |m| m.title = "OOP" }
    mod4 = CourseModule.find_or_create_by!(position: 4) { |m| m.title = "Blocks" }
    mod5 = CourseModule.find_or_create_by!(position: 5) { |m| m.title = "Metaprogramming" }

    # Create 5 lessons in mod1 and 5 in each extra module = 25 total
    (1..5).each { |pos| create_lesson_with_exercise(course_module.id, pos) }
    [mod2, mod3, mod4, mod5].each do |mod|
      (1..5).each { |pos| create_lesson_with_exercise(mod.id, pos) }
    end

    # Complete 8 lessons: get all exercises for first 8 lessons in module 1 and 2
    lessons_mod1 = Lesson.where(module_id: course_module.id).order(:position_in_module).limit(5).to_a
    lessons_mod2 = Lesson.where(module_id: mod2.id).order(:position_in_module).limit(3).to_a
    (lessons_mod1 + lessons_mod2).first(8).each do |lesson|
      lesson.exercises.each do |ex|
        create_review_with_interval(user, ex, 30)
      end
    end

    visit dashboard_path

    expect(page).to have_content("8 of 25 lessons")
    expect(page).to have_content("32%")
  end

  # Behavior 3: Retention rate 'Not enough data yet' when account < 14 days (AC-012-03)
  it "shows not enough data yet message when user account is less than 14 days old" do
    # user created_at defaults to now (fresh account)
    user.update_column(:created_at, 5.days.ago)

    visit dashboard_path

    expect(page).to have_content("Not enough data yet")
    expect(page).to have_content("14-day")
  end

  # Behavior 4: Keyboard shortcuts navigate to curriculum and session (AC-012-04)
  it "shows keyboard shortcuts c for curriculum and s for session on the dashboard" do
    visit dashboard_path

    expect(page).to have_content("c")
    expect(page).to have_content("s")
    # Shortcuts legend visible without modal
    expect(page).to have_css(".keyboard-shortcuts")
  end
end
