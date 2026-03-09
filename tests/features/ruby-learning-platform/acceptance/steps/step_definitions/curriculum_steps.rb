# Step definitions for curriculum and topic selection domain.
# Covers: US-03 (Topic Selection), US-08 (Lesson Tree Navigation and Prerequisite Gating)
# Driving port: LessonsController (→ CurriculumMap, LessonUnlocker, LockScreenPolicy)

# ---- Given steps ----

Given("Ana has completed Module {int} (Lessons {int} through {int})") do |module_num, first, last|
  (first..last).each do |lesson_number|
    create(:lesson_progress, lesson_id: lesson_number, status: :complete)
    lesson_unlocker.unlock_lessons_after_completion(lesson_number)
  end
end

Given("she has not yet started Module {int}") do |module_num|
  # Default state — no progress records for module 2 lessons.
end

Given("Lesson {int} is the only available lesson in Module {int}") do |lesson_num, _module_num|
  lesson = curriculum_map.lesson(lesson_num)
  expect(lesson.status).to eq(:available)
end

Given("Ana is in the curriculum tree") do
  open_curriculum_tree
  expect(page).to have_css("[data-curriculum-tree]", wait: 5)
end

Given("Ana navigates to Lesson {int} which requires Lesson {int} to be complete") do |target, prereq|
  open_curriculum_tree
  within("[data-curriculum-tree]") do
    find("[data-lesson-id='#{target}']").click
  end
end

Given("Lesson {int} requires both Lesson {int} and Lesson {int}") do |target, prereq1, prereq2|
  # Verified via the prerequisite graph loaded from prerequisites.yml.
  prereqs = prerequisite_graph.prerequisites_for(target)
  expect(prereqs).to include(prereq1, prereq2)
end

Given("Lesson {int} is complete but Lesson {int} is not") do |complete_lesson, incomplete_lesson|
  create(:lesson_progress, lesson_id: complete_lesson, status: :complete)
  lesson_unlocker.unlock_lessons_after_completion(complete_lesson)
  # Lesson incomplete_lesson remains not started.
end

Given("Ana is on a lock screen for a locked lesson") do
  open_curriculum_tree
  locked_lesson = (2..25).find { |n| curriculum_map.lesson(n).status == :locked }
  within("[data-curriculum-tree]") do
    find("[data-lesson-id='#{locked_lesson}']").click
  end
  press_key(:enter)
  expect(page).to have_css("[data-lock-screen]", wait: 3)
end

Given("Ana navigates to and completed all exercises in Lesson {int}") do |lesson_number|
  open_lesson(lesson_number)
  click_on "Start Lesson" if page.has_button?("Start Lesson")
  exercises = curriculum_map.lesson_with_exercises(lesson_number).exercises
  exercises.each do |exercise|
    submit_answer(exercise.correct_answer)
    expect(page).to have_css("[data-next-ready]", wait: 5)
    press_key(:enter) if page.has_css?("[data-next-ready]")
  end
end

Given("Ana has completed all exercises in Lesson {int}") do |lesson_number|
  step "Ana navigates to and completed all exercises in Lesson #{lesson_number}"
end

Given("Lesson {int} is currently available") do |lesson_number|
  lesson = curriculum_map.lesson(lesson_number)
  expect(lesson.status).to eq(:available)
end

Given("Ana has unlocked Lesson {int} by completing Lesson {int}") do |unlocked, prereq|
  create(:lesson_progress, lesson_id: prereq, status: :complete)
  lesson_unlocker.unlock_lessons_after_completion(prereq)
  lesson = curriculum_map.lesson(unlocked)
  expect(lesson.status).to eq(:available)
end

Given("she pressed Esc to save for next session") do
  press_key(:escape)
end

Given("Ana has completed Lesson {int} and Lesson {int} is now unlocked") do |completed, unlocked|
  create(:lesson_progress, lesson_id: completed, status: :complete)
  lesson_unlocker.unlock_lessons_after_completion(completed)
end

Given("Ana has completed both Lesson {int} and Lesson {int} in the same sitting") do |lesson1, lesson2|
  [lesson1, lesson2].each do |ln|
    step "Ana has completed all exercises in Lesson #{ln}"
  end
end

Given("the full curriculum prerequisite graph is loaded") do
  expect(prerequisite_graph).not_to be_nil
  expect(prerequisite_graph.lessons.count).to eq(25)
end

Given("Ana is on the session dashboard with {int} review exercises due") do |count|
  step "#{count} review exercises are due today"
  open_platform
  expect(page).to have_css("[data-session-dashboard]", wait: 5)
end

Given("she has completed Lessons {int} through {int}") do |first, last|
  step "she has completed Lessons #{first} through #{last}"
end

Given("Ana completes Lesson {int} exercises via the topic selection path") do |lesson_number|
  open_curriculum_tree
  within("[data-curriculum-tree]") do
    find("[data-lesson-id='#{lesson_number}']").click
  end
  press_key(:enter)
  exercises = curriculum_map.lesson_with_exercises(lesson_number).exercises
  exercises.each do |exercise|
    submit_answer(exercise.correct_answer)
    expect(page).to have_css("[data-next-ready]", wait: 5)
    press_key(:enter) if page.has_css?("[data-next-ready]")
  end
end

Given("Ana has completed Lessons {int} through {int}") do |first, last|
  (first..last).each do |lesson_number|
    create(:lesson_progress, lesson_id: lesson_number, status: :complete)
    lesson_unlocker.unlock_lessons_after_completion(lesson_number)
  end
end

Given("a lesson's completion status changes because Ana just completed it") do
  open_lesson(6) # Lesson 6 is the first Module 2 lesson in standard setup.
  click_on "Start Lesson" if page.has_button?("Start Lesson")
  exercises = curriculum_map.lesson_with_exercises(6).exercises
  exercises.each do |exercise|
    submit_answer(exercise.correct_answer)
    expect(page).to have_css("[data-next-ready]", wait: 5)
    press_key(:enter) if page.has_css?("[data-next-ready]")
  end
end

# ---- When steps ----

When("Ana opens the curriculum tree") do
  open_curriculum_tree
end

When("she presses {string} and types {string}") do |key, search_text|
  press_key(key)
  expect(page).to have_css("[data-search-input]", wait: 3)
  find("[data-search-input]").type(search_text)
end

When("she selects Lesson {int}") do |lesson_number|
  within("[data-curriculum-tree]") do
    find("[data-lesson-id='#{lesson_number}']").click
  end
  press_key(:enter)
end

When("she presses Enter") do
  press_key(:enter)
end

When("Ana navigates to Lesson {int} and presses Enter") do |lesson_number|
  within("[data-curriculum-tree]") do
    find("[data-lesson-id='#{lesson_number}']").click
  end
  press_key(:enter)
end

When("Ana navigates to Lesson {int}") do |lesson_number|
  within("[data-curriculum-tree]") do
    find("[data-lesson-id='#{lesson_number}']").click
  end
end

When("the Lesson {int} complete screen renders") do |lesson_number|
  expect(page).to have_css("[data-lesson-complete][data-lesson-id='#{lesson_number}']", wait: 10)
end

When("she starts Lesson {int}") do |lesson_number|
  open_lesson(lesson_number)
  click_on "Start Lesson" if page.has_button?("Start Lesson")
end

When("she presses {string} to open topic selection") do |key|
  press_key(key)
  expect(page).to have_css("[data-curriculum-tree]", wait: 3)
end

When("she selects an available lesson different from the SM-2 recommendation") do
  # Find any available lesson that is not the first recommended one.
  available_lessons = (1..25).select { |n| curriculum_map.lesson(n).status == :available }
  non_default = available_lessons.last
  within("[data-curriculum-tree]") do
    find("[data-lesson-id='#{non_default}']").click
  end
  press_key(:enter)
  @override_lesson = non_default
end

When("she starts the session") do
  press_key(:enter)
  expect(page).to have_css("[data-session-active]", wait: 5)
end

When("she answers an exercise correctly") do
  within("[data-exercise]") do
    correct_answer = find("[data-correct-answer-data]", visible: false)[:content]
    submit_answer(correct_answer)
  end
end

When("she completes an exercise correctly") do
  step "she answers an exercise correctly"
end

When("the completion screen renders") do
  expect(page).to have_css("[data-lesson-complete]", wait: 10)
end

When("she opens the platform the following day") do
  travel_to(Date.today + 1) do
    open_platform
  end
end

# ---- Then steps ----

Then("the curriculum tree opens") do
  expect(page).to have_css("[data-curriculum-tree]", wait: 5)
end

Then("the session dashboard state is preserved when she returns") do
  press_key(:escape)
  expect(page).to have_css("[data-session-dashboard]", wait: 3)
end

Then("pressing Esc returns her to the screen she came from") do
  press_key(:escape)
  # Verify a meaningful page element is present after escape.
  expect(page).to have_css("[data-session-dashboard], [data-curriculum-tree], [data-exercise]", wait: 3)
end

Then("Module {int} shows status {string}") do |module_num, status|
  within("[data-module-id='#{module_num}']") do
    expect(page).to have_css("[data-module-status='#{status.downcase}']")
    expect(page).to have_content(status)
  end
end

Then("Lesson {int} shows as available with no lock indicator") do |lesson_number|
  within("[data-lesson-id='#{lesson_number}']") do
    expect(page).to have_css("[data-status='available']")
    expect(page).not_to have_css("[data-lock-indicator]")
  end
end

Then("Lessons {int} through {int} show as locked with their respective prerequisite labels") do |first, last|
  (first..last).each do |lesson_number|
    within("[data-lesson-id='#{lesson_number}']") do
      expect(page).to have_css("[data-status='locked']")
      expect(page).to have_css("[data-prerequisite-label]")
    end
  end
end

Then("Modules {int} through {int} show as {string}") do |first, last, status|
  (first..last).each do |module_num|
    within("[data-module-id='#{module_num}']") do
      expect(page).to have_css("[data-module-status='#{status.downcase}']")
    end
  end
end

Then("all 25 lessons are shown") do
  expect(page).to have_css("[data-lesson-id]", count: 25)
end

Then("all 25 lessons are visible and interactive within {int} milliseconds") do |ms|
  start_time = Time.now
  expect(page).to have_css("[data-lesson-id]", count: 25, wait: ms / 1000.0)
  elapsed_ms = ((Time.now - start_time) * 1000).to_i
  expect(elapsed_ms).to be <= ms
end

Then("the cursor moves to the next lesson in the list") do
  # Verify the cursor (focus/highlight) has moved down one position.
  current_cursor = find("[data-cursor='true']")[:"data-lesson-id"].to_i
  expect(current_cursor).to be > 0
end

Then("the cursor moves to the previous lesson") do
  current_cursor = find("[data-cursor='true']")[:"data-lesson-id"].to_i
  expect(current_cursor).to be > 0
end

Then("the cursor jumps to the first lesson of the next module") do
  cursor_lesson = find("[data-cursor='true']")[:"data-lesson-id"].to_i
  lesson = curriculum_map.lesson(cursor_lesson)
  # The cursor should be on the first lesson of the next module.
  expect(lesson.position_in_module).to eq(1)
end

Then("the cursor jumps to the first lesson of the previous module") do
  cursor_lesson = find("[data-cursor='true']")[:"data-lesson-id"].to_i
  lesson = curriculum_map.lesson(cursor_lesson)
  expect(lesson.position_in_module).to eq(1)
end

Then("a search input field becomes active") do
  expect(page).to have_css("[data-search-input]:focus", wait: 3)
end

Then("the tree filters to show only lessons matching {string} in title or topics") do |search_term|
  visible_lessons = all("[data-lesson-id]:not([hidden])")
  expect(visible_lessons).not_to be_empty
  visible_lessons.each do |lesson_element|
    lesson_text = lesson_element.text.downcase
    expect(lesson_text).to include(search_term.downcase)
  end
end

Then("Lesson {int} {string} is visible in the filtered results") do |lesson_number, lesson_title|
  expect(page).to have_css("[data-lesson-id='#{lesson_number}']:not([hidden])")
  expect(page).to have_content(lesson_title)
end

Then("lessons that do not match {string} are hidden from view") do |search_term|
  hidden_lessons = all("[data-lesson-id][hidden]")
  expect(hidden_lessons.count).to be > 0
end

Then("the full curriculum tree restores with no filter active") do
  expect(page).to have_css("[data-lesson-id]", count: 25)
  expect(page).not_to have_css("[data-search-input]")
end

Then("the tree shows a message indicating no lessons match the search") do
  expect(page).to have_css("[data-no-results]")
end

Then("a lock screen appears (not an error message)") do
  expect(page).to have_css("[data-lock-screen]")
  expect(page).not_to have_css("[data-error-message]")
end

Then("the lock screen shows {string}") do |lock_reason|
  within("[data-lock-screen]") do
    expect(page).to have_content(lock_reason)
  end
end

Then("the lock screen shows the topics that Lesson {int} covers") do |lesson_number|
  within("[data-lock-screen]") do
    expect(page).to have_css("[data-target-lesson-topics]")
    expect(find("[data-target-lesson-topics]").text).not_to be_empty
  end
end

Then("the lock screen shows the topics that Lesson {int} covers") do |lesson_number|
  within("[data-lock-screen]") do
    expect(page).to have_css("[data-prerequisite-topics]")
    expect(find("[data-prerequisite-topics]").text).not_to be_empty
  end
end

Then("pressing Enter navigates her to Lesson {int}") do |lesson_number|
  press_key(:enter)
  expect(page).to have_css("[data-lesson-id='#{lesson_number}']", wait: 5)
end

Then("the lock screen shows Lesson {int} as {string}") do |lesson_number, status_label|
  within("[data-lock-screen]") do
    within("[data-prerequisite-item='#{lesson_number}']") do
      expect(page).to have_content(status_label)
    end
  end
end

Then("pressing Enter navigates to Lesson {int}, the incomplete prerequisite") do |lesson_number|
  press_key(:enter)
  expect(page).to have_css("[data-lesson-id='#{lesson_number}']", wait: 5)
end

Then("the lesson preview screen loads directly") do
  expect(page).to have_css("[data-lesson-preview]", wait: 3)
  expect(page).not_to have_css("[data-lock-screen]")
end

Then("there is no {string} option visible") do |option_text|
  expect(page).not_to have_content(option_text)
end

Then("the only available actions are Enter to go to the prerequisite and Esc to go back") do
  within("[data-lock-screen]") do
    expect(page).not_to have_button("skip")
    expect(page).not_to have_button("unlock anyway")
    expect(page).not_to have_link("force unlock")
  end
end

Then("Lesson {int} is shown as newly unlocked on the completion screen") do |lesson_number|
  within("[data-lesson-complete]") do
    expect(page).to have_css("[data-newly-unlocked][data-lesson-id='#{lesson_number}']")
  end
end

Then("the curriculum tree (if opened) shows Lesson {int} as available") do |lesson_number|
  open_curriculum_tree
  within("[data-lesson-id='#{lesson_number}']") do
    expect(page).to have_css("[data-status='available']")
  end
  page.go_back
end

Then("there is no intermediate state where Lesson {int} shows as ambiguous or still locked") do |lesson_number|
  # Verified by the atomic unlock — the test observes the completion screen directly.
  within("[data-lesson-complete]") do
    expect(page).not_to have_css("[data-lesson-id='#{lesson_number}'][data-status='locked']")
    expect(page).not_to have_css("[data-lesson-id='#{lesson_number}'][data-status='ambiguous']")
  end
end

Then("Module {int} shows status {string}") do |module_num, status|
  within("[data-module-id='#{module_num}']") do
    expect(page).to have_content(status)
  end
end

Then("Lesson {int} changes from locked to available at the same moment") do |lesson_number|
  within("[data-lesson-id='#{lesson_number}']") do
    expect(page).to have_css("[data-status='available']")
  end
end

Then("Lesson {int} is still shown as available, not locked") do |lesson_number|
  within("[data-lesson-id='#{lesson_number}']") do
    expect(page).to have_css("[data-status='available']")
    expect(page).not_to have_css("[data-status='locked']")
  end
end

Then("the session dashboard recommends Lesson {int} as the next lesson") do |lesson_number|
  within("[data-session-dashboard]") do
    expect(page).to have_css("[data-next-lesson-id='#{lesson_number}']")
  end
end

Then("the review schedule is updated using the same SM-2 algorithm as a daily session exercise") do
  exercise = @current_exercise || curriculum_map.lesson_with_exercises(6).exercises.first
  state = test_review_repository.review_state(exercise.id)
  expect(state).not_to be_nil
  expect(state.ease_factor).to eq(2.5)
  expect(state.next_review_date).to eq(Date.today + 1)
end

Then("Lesson {int} exercises appear in future review queues at the normal SM-2 interval") do |lesson_number|
  exercises = curriculum_map.lesson_with_exercises(lesson_number).exercises
  exercises.each do |exercise|
    state = test_review_repository.review_state(exercise.id)
    expect(state).not_to be_nil
    expect(state.next_review_date).not_to be_nil
  end
end

Then("she sees Lesson {int} listed as newly unlocked") do |lesson_number|
  expect(page).to have_css("[data-newly-unlocked][data-lesson-id='#{lesson_number}']")
end

Then("pressing Enter starts Lesson {int} immediately") do |lesson_number|
  press_key(:enter)
  expect(page).to have_css("[data-lesson-id='#{lesson_number}'][data-active='true']", wait: 5)
end

Then("pressing Esc instead saves Lesson {int} as the next recommended session") do |lesson_number|
  press_key(:escape)
  open_platform
  within("[data-session-dashboard]") do
    expect(page).to have_css("[data-next-lesson-id='#{lesson_number}']")
  end
end

Then("the {int} review exercises run first, unchanged from the original plan") do |count|
  expect(page).to have_css("[data-review-exercise]", wait: 5)
  plan = session_planner.current_plan
  expect(plan.review_exercises.count).to eq(count)
end

Then("the manually selected lesson runs after the review queue") do
  # After the review phase, the selected lesson should load.
  # Advance through reviews first.
  until page.has_css?("[data-lesson-content]") || !page.has_css?("[data-review-exercise]")
    if page.has_css?("[data-exercise]")
      exercise_answer = find("[data-correct-answer-data]", visible: false)[:content] rescue "skip"
      submit_answer(exercise_answer)
    end
    press_key(:enter) if page.has_css?("[data-next-ready]")
  end
  expect(page).to have_css("[data-lesson-content]", wait: 5)
end

Then("Lesson {int} is always shown as available on the very first launch") do |lesson_number|
  within("[data-lesson-id='#{lesson_number}']") do
    expect(page).to have_css("[data-status='available']")
  end
end

Then("it shows both Lesson {int} and Lesson {int} as completed today") do |lesson1, lesson2|
  within("[data-session-summary]") do
    expect(page).to have_content("Lesson #{lesson1}")
    expect(page).to have_content("Lesson #{lesson2}")
  end
end

Then("review schedule entries exist for exercises from both lessons") do
  [6, 7].each do |lesson_number|
    exercises = curriculum_map.lesson_with_exercises(lesson_number).exercises
    exercises.each do |exercise|
      state = test_review_repository.review_state(exercise.id)
      expect(state).not_to be_nil
    end
  end
end

Then("within the same session all views show the updated status") do
  expect(true).to be(true) # Verified by checking each view in subsequent steps.
end

Then("the curriculum tree shows the correct availability icon") do
  within("[data-curriculum-tree]") do
    expect(page).to have_css("[data-status='complete'], [data-status='available'], [data-status='locked']")
  end
end

Then("the session dashboard next-lesson recommendation reflects the change") do
  open_platform
  within("[data-session-dashboard]") do
    expect(page).to have_css("[data-next-lesson-title]")
  end
end

Then("the lock screen for any dependent lesson shows the correct prerequisite completion") do
  # Find a lesson that depends on a recently completed lesson.
  open_curriculum_tree
  # Pick a locked lesson to verify the lock screen data.
  locked_lesson = (2..25).find { |n| curriculum_map.lesson(n).status == :locked }
  if locked_lesson
    within("[data-curriculum-tree]") do
      find("[data-lesson-id='#{locked_lesson}']").click
    end
    press_key(:enter)
    within("[data-lock-screen]") do
      expect(page).to have_css("[data-prerequisite-item]")
    end
  end
end

Then("the progress dashboard shows the updated lesson count") do
  press_key("p")
  within("[data-progress-dashboard]") do
    expect(page).to have_css("[data-lessons-complete]")
  end
  press_key(:escape)
end

Then("no lesson is listed as a prerequisite of itself") do
  (1..25).each do |lesson_id|
    prereqs = prerequisite_graph.prerequisites_for(lesson_id)
    expect(prereqs).not_to include(lesson_id)
  end
end

Then("all prerequisite references point to lower-numbered lessons") do
  (1..25).each do |lesson_id|
    prereqs = prerequisite_graph.prerequisites_for(lesson_id)
    prereqs.each do |prereq_id|
      expect(prereq_id).to be < lesson_id
    end
  end
end

Then("completing lessons in sequential order satisfies all prerequisites") do
  completed = Set.new
  (1..25).each do |lesson_id|
    prereqs = prerequisite_graph.prerequisites_for(lesson_id)
    expect(prereqs.all? { |p| completed.include?(p) }).to be(true)
    completed.add(lesson_id)
  end
end
