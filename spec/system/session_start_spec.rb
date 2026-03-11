require "rails_helper"

# Test Budget: 4 behaviors x 2 = 8 max unit tests (using 4 system tests)
# Behavior 1: Session start screen shows exercises by lesson (concept), estimated time, '15:00' budget, streak count (AC-004-01)
# Behavior 2: Empty queue shows rest-day message, streak unchanged (AC-004-03)
# Behavior 3: POST to sessions_path creates session row (AC-004-04)
# Behavior 4: Keyboard shortcuts for starting a session visible without help modal (XC-004)

RSpec.describe "Session start screen", type: :system do
  let!(:course_module) do
    CourseModule.find_or_create_by!(id: 3) do |m|
      m.title = "Session Start Test Module"
      m.position = 3
    end
  end

  let!(:lesson_variables) do
    Lesson.find_or_create_by!(module_id: course_module.id, position_in_module: 1) do |l|
      l.title = "Variables"
      l.content_body = "Variables in Ruby."
      l.python_equivalent = "Python variables."
      l.java_equivalent = "Java variables."
      l.estimated_minutes = 3
      l.prerequisite_ids = []
    end
  end

  let!(:lesson_blocks) do
    Lesson.find_or_create_by!(module_id: course_module.id, position_in_module: 2) do |l|
      l.title = "Blocks"
      l.content_body = "Blocks in Ruby."
      l.python_equivalent = "Python lambdas."
      l.java_equivalent = "Java lambdas."
      l.estimated_minutes = 4
      l.prerequisite_ids = []
    end
  end

  let!(:lesson_hashes) do
    Lesson.find_or_create_by!(module_id: course_module.id, position_in_module: 3) do |l|
      l.title = "Hashes"
      l.content_body = "Hashes in Ruby."
      l.python_equivalent = "Python dicts."
      l.java_equivalent = "Java maps."
      l.estimated_minutes = 3
      l.prerequisite_ids = []
    end
  end

  let!(:lesson_loops) do
    Lesson.find_or_create_by!(module_id: course_module.id, position_in_module: 4) do |l|
      l.title = "Loops"
      l.content_body = "Loops in Ruby."
      l.python_equivalent = "Python loops."
      l.java_equivalent = "Java loops."
      l.estimated_minutes = 5
      l.prerequisite_ids = []
    end
  end

  let!(:exercise_variables) do
    Exercise.find_or_create_by!(lesson_id: lesson_variables.id, position: 3) do |e|
      e.exercise_type = "fill_in_blank"
      e.prompt = "Variables exercise"
      e.correct_answer = "x"
      e.accepted_synonyms = []
      e.explanation = "Variables explanation."
      e.options = []
    end
  end

  let!(:exercise_blocks) do
    Exercise.find_or_create_by!(lesson_id: lesson_blocks.id, position: 3) do |e|
      e.exercise_type = "fill_in_blank"
      e.prompt = "Blocks exercise"
      e.correct_answer = "block"
      e.accepted_synonyms = []
      e.explanation = "Blocks explanation."
      e.options = []
    end
  end

  let!(:exercise_hashes) do
    Exercise.find_or_create_by!(lesson_id: lesson_hashes.id, position: 3) do |e|
      e.exercise_type = "fill_in_blank"
      e.prompt = "Hashes exercise"
      e.correct_answer = "hash"
      e.accepted_synonyms = []
      e.explanation = "Hashes explanation."
      e.options = []
    end
  end

  let!(:exercise_loops) do
    Exercise.find_or_create_by!(lesson_id: lesson_loops.id, position: 3) do |e|
      e.exercise_type = "fill_in_blank"
      e.prompt = "Loops exercise"
      e.correct_answer = "loop"
      e.accepted_synonyms = []
      e.explanation = "Loops explanation."
      e.options = []
    end
  end

  let!(:user_with_queue) do
    User.find_or_create_by!(email: "session_start_test@example.com") do |u|
      u.password = "password123"
      u.experience_level = "expert"
      u.timezone = "UTC"
      u.streak_count = 7
    end
  end

  let!(:user_empty_queue) do
    User.find_or_create_by!(email: "session_start_empty@example.com") do |u|
      u.password = "password123"
      u.experience_level = "expert"
      u.timezone = "UTC"
      u.streak_count = 3
    end
  end

  def create_review_for(user, exercise)
    Review.find_or_create_by!(user: user, exercise: exercise) do |r|
      r.next_review_date = Date.current
      r.answer_result = "correct"
      r.quality_score = 4
      r.sm2_interval = 1
      r.sm2_ease_factor = 2.5
      r.repetitions = 1
    end
  end

  # Behavior 1: 4 exercises due today show lesson titles (concept names), '15:00' budget, streak count (AC-004-01)
  it "shows exercises by lesson title, budget 15:00, and streak count" do
    create_review_for(user_with_queue, exercise_variables)
    create_review_for(user_with_queue, exercise_blocks)
    create_review_for(user_with_queue, exercise_hashes)
    create_review_for(user_with_queue, exercise_loops)

    allow(User).to receive(:first).and_return(user_with_queue)

    visit new_session_path

    expect(page).to have_content("Variables")
    expect(page).to have_content("Blocks")
    expect(page).to have_content("Hashes")
    expect(page).to have_content("Loops")
    expect(page).to have_content("15:00")
    expect(page).to have_content("7")
  end

  # Behavior 2: Empty queue shows rest-day message, streak count unchanged (AC-004-03)
  it "shows rest-day message when no exercises are due today" do
    allow(User).to receive(:first).and_return(user_empty_queue)

    streak_before = user_empty_queue.streak_count

    visit new_session_path

    expect(page).to have_content("Nothing due today")
    expect(user_empty_queue.reload.streak_count).to eq(streak_before)
  end

  # Behavior 3: POST to sessions_path creates a session row for the user (AC-004-04)
  it "creates a session row when the session is started" do
    allow(User).to receive(:first).and_return(user_with_queue)

    expect {
      page.driver.post(sessions_path)
    }.to change(LearningSession, :count).by(1)

    session = LearningSession.last
    expect(session.user_id).to eq(user_with_queue.id)
  end

  # Behavior 4: Keyboard shortcuts visible on session start screen without help modal (XC-004)
  it "displays keyboard shortcuts to start session without requiring any modal interaction" do
    allow(User).to receive(:first).and_return(user_with_queue)

    visit new_session_path

    expect(page).to have_css(".keyboard-shortcuts")
    expect(page).to have_content("Enter")
    expect(page).to have_content("s")
  end
end
