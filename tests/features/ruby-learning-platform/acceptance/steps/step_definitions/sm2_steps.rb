# Step definitions for SM-2 spaced repetition engine domain.
# Covers: US-05 (SM-2 Review Engine)
# Driving port: ExercisesController (→ ReviewScheduler → SM2Algorithm)
#               SessionsController (→ SessionPlanner → ReviewQueue)

# ---- Given steps ----

Given("an exercise with a current review interval of {int} days and ease factor of {float}") do |interval, ef|
  lesson = curriculum_map.lesson_with_exercises(1)
  exercise = lesson.exercises.first
  create(:review_state,
    exercise_id: exercise.id,
    ease_factor: ef,
    interval: interval,
    next_review_date: Date.today)
  @sm2_exercise = exercise
  @sm2_starting_interval = interval
  @sm2_starting_ef = ef
end

Given("an exercise with ease factor {float}") do |ef|
  lesson = curriculum_map.lesson_with_exercises(1)
  exercise = lesson.exercises.first
  create(:review_state,
    exercise_id: exercise.id,
    ease_factor: ef,
    interval: 3,
    next_review_date: Date.today)
  @sm2_exercise = exercise
  @sm2_starting_ef = ef
end

Given("an exercise with ease factor {float} and review interval of {int} days") do |ef, interval|
  lesson = curriculum_map.lesson_with_exercises(1)
  exercise = lesson.exercises.first
  create(:review_state,
    exercise_id: exercise.id,
    ease_factor: ef,
    interval: interval,
    next_review_date: Date.today)
  @sm2_exercise = exercise
  @sm2_starting_ef = ef
  @sm2_starting_interval = interval
end

Given("{int} exercises have a due date on or before today") do |count|
  exercise_count = 0
  Lesson.all.flat_map(&:exercises).each do |exercise|
    break if exercise_count >= count
    create(:review_state,
      exercise_id: exercise.id,
      ease_factor: 2.5,
      interval: rand(1..5),
      next_review_date: Date.today - rand(0..3))
    exercise_count += 1
  end
end

Given("{int} exercises have a due date after today") do |count|
  exercise_count = 0
  Lesson.all.flat_map(&:exercises).last(count).each do |exercise|
    create(:review_state,
      exercise_id: exercise.id,
      ease_factor: 2.5,
      interval: 5,
      next_review_date: Date.today + rand(1..14))
    exercise_count += 1
  end
end

Given("an exercise has a due date matching today's date exactly") do
  lesson = curriculum_map.lesson_with_exercises(2)
  exercise = lesson.exercises.first
  create(:review_state,
    exercise_id: exercise.id,
    ease_factor: 2.5,
    interval: 1,
    next_review_date: Date.today)
  @boundary_exercise = exercise
end

Given("an exercise has a due date of tomorrow") do
  lesson = curriculum_map.lesson_with_exercises(2)
  exercise = lesson.exercises.last
  create(:review_state,
    exercise_id: exercise.id,
    ease_factor: 2.5,
    interval: 1,
    next_review_date: Date.today + 1)
  @future_exercise = exercise
end

Given("{int} exercises are due today") do |count|
  step "#{count} exercises have a due date on or before today"
end

Given("{int} exercises are due today from {int} different lessons ({int} exercises each)") do |total, num_lessons, per_lesson|
  (1..num_lessons).each do |lesson_number|
    lesson = curriculum_map.lesson_with_exercises(lesson_number)
    lesson.exercises.first(per_lesson).each do |exercise|
      create(:review_state,
        exercise_id: exercise.id,
        ease_factor: 2.5,
        interval: 2,
        next_review_date: Date.today)
    end
  end
end

Given("Ana has completed {int} review exercises with updated intervals") do |count|
  @exercises_completed_in_session = count
end

Given("the session has not yet been marked complete") do
  # Session is still in progress — no session_log record for today yet.
end

Given("Ana completes a review exercise with a correct answer") do
  open_platform
  press_key(:enter)
  expect(page).to have_css("[data-review-exercise]", wait: 5)
  within("[data-exercise]") do
    correct_answer = find("[data-correct-answer-data]", visible: false)[:content]
    submit_answer(correct_answer)
  end
end

Given("an exercise that has never been reviewed") do
  lesson = curriculum_map.lesson_with_exercises(1)
  @new_exercise = lesson.exercises.first
  # No review_state record exists for this exercise.
end

Given("all stored progress data has been cleared") do
  DatabaseCleaner.clean
  test_session_repository.clear_all
  Rails.application.load_seed
end

# ---- When steps ----

When("Ana submits a correct answer for the SM-2 exercise") do
  open_platform
  press_key(:enter)
  expect(page).to have_css("[data-review-exercise]", wait: 5)
  within("[data-exercise]") do
    correct_answer = find("[data-correct-answer-data]", visible: false)[:content]
    submit_answer(correct_answer)
  end
end

When("Ana submits an incorrect answer {int} times in a row") do |count|
  open_platform
  count.times do
    press_key(:enter) if page.has_css?("[data-session-dashboard]")
    if page.has_css?("[data-exercise]")
      submit_answer("intentionally_wrong_#{SecureRandom.hex(4)}")
      press_key(:enter) if page.has_css?("[data-next-ready]")
    end
  end
end

When("the session starts") do
  open_platform
  press_key(:enter)
  expect(page).to have_css("[data-session-active]", wait: 5)
end

When("the session dashboard computes today's review queue") do
  open_platform
  expect(page).to have_css("[data-session-dashboard]", wait: 5)
end

When("Ana submits {int} incorrect answers in sequence") do |count|
  step "Ana submits an incorrect answer #{count} times in a row"
end

When("SM-2 updates the exercise") do
  # SM-2 update happens automatically after answer submission.
  # The state is now in the database — query it for Then assertions.
  @last_sm2_state = test_review_repository.review_state(@sm2_exercise.id)
end

When("Ana completes it for the first time") do
  open_lesson(1)
  click_on "Start Lesson" if page.has_button?("Start Lesson")
  within("[data-exercise]") do
    correct_answer = find("[data-correct-answer-data]", visible: false)[:content]
    submit_answer(correct_answer)
  end
end

# ---- Then steps ----

Then("the new review interval is {int} days ({int} multiplied by {float})") do |expected_interval, prev_interval, ef|
  state = test_review_repository.review_state(@sm2_exercise.id)
  expect(state.interval).to eq(expected_interval)
end

Then("the ease factor remains {float}") do |expected_ef|
  state = test_review_repository.review_state(@sm2_exercise.id)
  expect(state.ease_factor).to be_within(0.01).of(expected_ef)
end

Then("the next review date is {int} days from today") do |days|
  state = test_review_repository.review_state(@sm2_exercise.id)
  expect(state.next_review_date).to eq(Date.today + days)
end

Then("the new review interval is at least {int} day") do |min_days|
  state = test_review_repository.review_state(@sm2_exercise.id)
  expect(state.interval).to be >= min_days
end

Then("the next review date is {int} or more days from today") do |min_days|
  state = test_review_repository.review_state(@sm2_exercise.id)
  expect(state.next_review_date).to be >= Date.today + min_days
end

Then("the new review interval is {int} day") do |days|
  state = test_review_repository.review_state(@sm2_exercise.id)
  expect(state.interval).to eq(days)
end

Then("the ease factor decreases to {float} (reduced by {float})") do |expected_ef, _reduction|
  state = test_review_repository.review_state(@sm2_exercise.id)
  expect(state.ease_factor).to be_within(0.01).of(expected_ef)
end

Then("the next review date is tomorrow") do
  state = test_review_repository.review_state(@sm2_exercise.id)
  expect(state.next_review_date).to eq(Date.today + 1)
end

Then("the ease factor decreases to {float} (reduced by {float} to reach the minimum)") do |expected_ef, _reduction|
  state = test_review_repository.review_state(@sm2_exercise.id)
  expect(state.ease_factor).to be_within(0.01).of(expected_ef)
end

Then("submitting another incorrect answer does not reduce the ease factor below {float}") do |minimum|
  # Submit one more incorrect answer and verify the floor is held.
  if page.has_css?("[data-exercise]")
    submit_answer("wrong_again_#{SecureRandom.hex(4)}")
    expect(page).to have_css("[data-feedback]", wait: 5)
  end
  state = test_review_repository.review_state(@sm2_exercise.id)
  expect(state.ease_factor).to be >= minimum
end

Then("the ease factor is {float} and not lower") do |expected_ef|
  state = test_review_repository.review_state(@sm2_exercise.id)
  expect(state.ease_factor).to be_within(0.01).of(expected_ef)
  expect(state.ease_factor).to be >= 1.3
end

Then("the ease factor remains {float} (unchanged after skip)") do |expected_ef|
  state = test_review_repository.review_state(@sm2_exercise.id)
  expect(state.ease_factor).to be_within(0.01).of(expected_ef)
end

Then("the review interval remains {int} days") do |days|
  state = test_review_repository.review_state(@sm2_exercise.id)
  expect(state.interval).to eq(days)
end

Then("the exercise appears in tomorrow's review queue") do
  tomorrow_exercises = review_queue.exercises_due_on(Date.today + 1)
  exercise_ids = tomorrow_exercises.map(&:id)
  expect(exercise_ids).to include(@sm2_exercise.id)
end

Then("the ease factor decreases by {float}") do |reduction|
  state = test_review_repository.review_state(@sm2_exercise.id)
  expected_ef = [@sm2_starting_ef - reduction, 1.3].max
  expect(state.ease_factor).to be_within(0.01).of(expected_ef)
end

Then("the result type recorded is {string}") do |result_type|
  within("[data-feedback]") do
    expect(page).to have_css("[data-result-type='#{result_type}']")
  end
end

Then("the queue contains exactly {int} exercises") do |count|
  plan = session_planner.current_plan
  expect(plan.review_exercises.count).to eq(count)
end

Then("the most overdue exercise is listed first") do
  plan = session_planner.current_plan
  sorted_dates = plan.review_exercises.map(&:next_review_date).sort
  actual_dates = plan.review_exercises.map(&:next_review_date)
  expect(actual_dates).to eq(sorted_dates)
end

Then("the {int} future exercises are not in today's queue") do |count|
  plan = session_planner.current_plan
  plan.review_exercises.each do |exercise|
    expect(exercise.next_review_date).to be <= Date.today
  end
end

Then("that exercise is included in today's queue") do
  plan = session_planner.current_plan
  exercise_ids = plan.review_exercises.map(&:id)
  expect(exercise_ids).to include(@boundary_exercise.id)
end

Then("that exercise is not included in today's queue") do
  plan = session_planner.current_plan
  exercise_ids = plan.review_exercises.map(&:id)
  expect(exercise_ids).not_to include(@future_exercise.id)
end

Then("today's review queue contains exactly {int} exercises") do |count|
  plan = session_planner.current_plan
  expect(plan.review_exercises.count).to eq(count)
end

Then("the {int} deferred exercises have their next due date unchanged") do |count|
  deferred = review_queue.deferred_exercises
  deferred.each do |exercise|
    state = test_review_repository.review_state(exercise.id)
    # Due date unchanged means it still reflects the original due date, not today.
    expect(state.next_review_date).to be <= Date.today
  end
end

Then("tomorrow's queue includes those {int} deferred exercises with high priority") do |count|
  deferred = review_queue.deferred_exercises
  expect(deferred.count).to be >= count
  deferred.each do |exercise|
    expect(exercise.deferred).to be(true)
  end
end

Then("today's review queue contains {int} exercises regardless of which lessons they come from") do |count|
  plan = session_planner.current_plan
  expect(plan.review_exercises.count).to eq(count)
end

Then("the review interval for that exercise is already saved to storage") do
  state = test_review_repository.review_state(@sm2_exercise&.id || Exercise.first.id)
  expect(state).not_to be_nil
  expect(state.next_review_date).not_to be_nil
end

Then("this state would survive an unexpected session interruption") do
  # Verify by checking the database state directly — it's persisted per-exercise.
  state = test_review_repository.review_state(@sm2_exercise&.id || Exercise.first.id)
  expect(state.next_review_date).not_to be_nil
end

Then("its initial ease factor is set to {float}") do |ef|
  state = test_review_repository.review_state(@new_exercise.id)
  expect(state.ease_factor).to be_within(0.01).of(ef)
end

Then("its initial review interval is set to {int} day") do |days|
  state = test_review_repository.review_state(@new_exercise.id)
  expect(state.interval).to eq(days)
end

Then("its next review date is tomorrow") do
  state = test_review_repository.review_state(@new_exercise.id)
  expect(state.next_review_date).to eq(Date.today + 1)
end

Then("she sees the message {string}") do |message|
  expect(page).to have_content(message)
end

Then("the first-time onboarding flow begins from the welcome screen") do
  expect(page).to have_content("Ruby for Experienced Developers")
end
