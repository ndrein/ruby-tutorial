# Step definitions for progress dashboard domain.
# Covers: US-09 (Progress Dashboard)
# Driving port: ProgressController (→ ProgressDashboard)

# ---- Given steps ----

Given("Ana has completed Lessons {int}-{int} and none others") do |first, last|
  (first..last).each do |lesson_number|
    create(:lesson_progress, lesson_id: lesson_number, status: :complete)
    lesson_unlocker.unlock_lessons_after_completion(lesson_number)
  end
end

Given("she has a {int}-day practice streak") do |days|
  days.times do |i|
    create(:session_log, completed_at: Date.today - (days - 1 - i))
  end
end

Given("Lesson {int} exercises have been reviewed {int} times in total") do |lesson_number, total_reviews|
  @lesson_review_count = total_reviews
  @lesson_for_retention = lesson_number
  exercises = curriculum_map.lesson_with_exercises(lesson_number).exercises
  exercise = exercises.first

  total_reviews.times do |i|
    result = i < @correct_for_retention.to_i ? :correct : :incorrect
    create(:review_log,
      exercise_id: exercise.id,
      result: result,
      reviewed_at: Date.today - (total_reviews - i))
  end
end

Given("{int} of those reviews were answered correctly") do |correct_count|
  @correct_for_retention = correct_count
  # This is set up in the previous step by parameterizing the result type.
  # Re-create the review logs with the correct distribution if needed.
  lesson_number = @lesson_for_retention || 3
  exercises = curriculum_map.lesson_with_exercises(lesson_number).exercises
  exercise = exercises.first

  # Clear and re-create with correct distribution.
  ReviewLog.where(exercise_id: exercise.id).delete_all
  total = @lesson_review_count || 10
  total.times do |i|
    result = i < correct_count ? :correct : :incorrect
    create(:review_log,
      exercise_id: exercise.id,
      result: result,
      reviewed_at: Date.today - (total - i))
  end
end

Given("Lesson {int} has been reviewed {int} times in total") do |lesson_number, total_reviews|
  @lesson_for_retention = lesson_number
  @lesson_review_count = total_reviews
  exercises = curriculum_map.lesson_with_exercises(lesson_number).exercises
  exercise = exercises.first

  total_reviews.times do |i|
    result = i < @correct_for_fewer_reviews.to_i ? :correct : :incorrect
    create(:review_log,
      exercise_id: exercise.id,
      result: result,
      reviewed_at: Date.today - (total_reviews - i))
  end
end

Given("{int} of those reviews were answered correctly") do |correct_count|
  @correct_for_fewer_reviews = correct_count
  lesson_number = @lesson_for_retention || 5
  exercises = curriculum_map.lesson_with_exercises(lesson_number).exercises
  exercise = exercises.first

  ReviewLog.where(exercise_id: exercise.id).delete_all
  total = @lesson_review_count || 4
  total.times do |i|
    result = i < correct_count ? :correct : :incorrect
    create(:review_log,
      exercise_id: exercise.id,
      result: result,
      reviewed_at: Date.today - (total - i))
  end
end

Given("Ana has completed {int} lessons with {int}% average retention") do |lesson_count, retention_pct|
  (1..lesson_count).each do |lesson_number|
    create(:lesson_progress, lesson_id: lesson_number, status: :complete)
  end
  # Retention is derived from SM-2 data, not stored separately.
end

Given("Ana is in the middle of a session") do
  open_platform
  press_key(:enter)
  expect(page).to have_css("[data-session-active]", wait: 5)
end

Given("Ana has opened the progress dashboard with {string} during a session") do |key|
  open_platform
  press_key(:enter)
  expect(page).to have_css("[data-session-active]", wait: 5)
  press_key(key)
  expect(page).to have_css("[data-progress-dashboard]", wait: 3)
end

Given("Ana has been completing approximately {int} lesson per day over the last {int} days") do |lessons_per_day, days|
  days.times do |i|
    create(:session_log,
      completed_at: Date.today - (days - 1 - i),
      lessons_completed: lessons_per_day)
  end
end

Given("Ana has not yet completed any lessons") do
  # Default state — no lesson_progress records.
end

Given("Lesson {int} has never been reviewed via SM-2") do |lesson_number|
  exercises = curriculum_map.lesson_with_exercises(lesson_number).exercises
  exercises.each do |exercise|
    ReviewLog.where(exercise_id: exercise.id).delete_all
  end
end

# ---- When steps ----

When("she opens the progress dashboard") do
  open_progress_dashboard
end

When("Ana opens the progress dashboard") do
  open_progress_dashboard
end

When("she views the progress dashboard") do
  open_progress_dashboard
end

When("Ana views the progress dashboard") do
  open_progress_dashboard
end

When("she presses {string}") do |key|
  press_key(key)
end

# ---- Then steps ----

Then("the progress dashboard opens as an overlay on top of the current screen") do
  expect(page).to have_css("[data-progress-dashboard]", wait: 3)
  # Verify the session screen is still present beneath the overlay.
  expect(page).to have_css("[data-session-active]")
end

Then("the review session state is fully preserved underneath") do
  expect(page).to have_css("[data-session-active]")
end

Then("the progress dashboard overlay closes") do
  expect(page).not_to have_css("[data-progress-dashboard]")
end

Then("the review session is exactly where she left it") do
  expect(page).to have_css("[data-session-active]")
end

Then("the progress dashboard opens") do
  expect(page).to have_css("[data-progress-dashboard]", wait: 3)
end

Then("she sees {string}") do |text|
  within("[data-progress-dashboard]") do
    expect(page).to have_content(text)
  end
end

Then("Module {int} shows {string}") do |module_num, progress_text|
  within("[data-progress-dashboard]") do
    within("[data-module-id='#{module_num}']") do
      expect(page).to have_content(progress_text)
    end
  end
end

Then("Modules {int} through {int} each show {string}") do |first, last, progress_pattern|
  (first..last).each do |module_num|
    within("[data-progress-dashboard]") do
      within("[data-module-id='#{module_num}']") do
        expect(page).to have_content(/#{Regexp.escape(progress_pattern).sub('N', '\d+')}/i)
      end
    end
  end
end

Then("she sees {string} lessons complete") do |count_text|
  within("[data-progress-dashboard]") do
    expect(page).to have_content(count_text)
  end
end

Then("Lesson {int} shows a retention score of {int}%") do |lesson_number, expected_pct|
  within("[data-progress-dashboard]") do
    within("[data-lesson-id='#{lesson_number}']") do
      expect(page).to have_css("[data-retention-score]")
      score_text = find("[data-retention-score]").text
      expect(score_text).to include("#{expected_pct}%")
    end
  end
end

Then("the score is labeled as {string}") do |label_text|
  within("[data-progress-dashboard]") do
    expect(page).to have_content(label_text)
  end
end

Then("the score is labeled as {string} based on the {int} available reviews") do |label_prefix, count|
  within("[data-progress-dashboard]") do
    expect(page).to have_content(/#{Regexp.escape(label_prefix)}.*#{count}/i)
  end
end

Then("a retention score is shown for each of the {int} completed lessons") do |count|
  within("[data-progress-dashboard]") do
    expect(page).to have_css("[data-retention-score]", count: count)
  end
end

Then("no score is shown for lessons that are locked or not yet started") do
  within("[data-progress-dashboard]") do
    locked_lesson_elements = all("[data-lesson-status='locked'], [data-lesson-status='available']")
    locked_lesson_elements.each do |element|
      expect(element).not_to have_css("[data-retention-score]")
    end
  end
end

Then("no badges appear on screen") do
  within("[data-progress-dashboard]") do
    expect(page).not_to have_css("[data-badge]")
    expect(page.text.downcase).not_to include("badge")
  end
end

Then("no XP or points values appear on screen") do
  within("[data-progress-dashboard]") do
    page_text = page.text.downcase
    expect(page_text).not_to match(/\bxp\b|\bpoints?\b/)
  end
end

Then("no level indicators appear on screen") do
  within("[data-progress-dashboard]") do
    expect(page).not_to have_css("[data-level]")
    expect(page.text.downcase).not_to match(/\blevel \d+/)
  end
end

Then("no achievement notifications appear on screen") do
  within("[data-progress-dashboard]") do
    expect(page).not_to have_css("[data-achievement]")
  end
end

Then("no congratulatory language beyond factual counts appears") do
  within("[data-progress-dashboard]") do
    page_text = page.text.downcase
    expect(page_text).not_to match(/congrat|amazing|great job|well done|you're on fire/i)
  end
end

Then("she sees {string} as the streak count") do |streak_text|
  within("[data-progress-dashboard]") do
    expect(page).to have_content(streak_text)
    expect(page).to have_css("[data-streak-count]")
  end
end

Then("the streak is not highlighted with special color or animation") do
  within("[data-progress-dashboard]") do
    streak_element = find("[data-streak-count]")
    expect(streak_element[:class]).not_to match(/highlight|achievement|celebration|pulse/i)
  end
end

Then("the streak is shown in the same visual style as other factual counts") do
  within("[data-progress-dashboard]") do
    streak_element = find("[data-streak-count]")
    # Verify no special styling classes are applied compared to other count elements.
    expect(streak_element[:class]).not_to match(/streak-highlight|special|featured/i)
  end
end

Then("she sees an estimated sessions remaining count based on her current pace") do
  within("[data-progress-dashboard]") do
    expect(page).to have_css("[data-sessions-remaining]")
    expect(find("[data-sessions-remaining]").text.to_i).to be > 0
  end
end

Then("the estimate is labeled as an approximation, not a guarantee") do
  within("[data-progress-dashboard]") do
    expect(page).to have_content(/approximately|estimate|~|about/i)
  end
end

Then("she sees {string}") do |text|
  within("[data-progress-dashboard]") do
    expect(page).to have_content(text)
  end
end

Then("all modules show {string}") do |pattern|
  within("[data-progress-dashboard]") do
    (1..5).each do |module_num|
      within("[data-module-id='#{module_num}']") do
        expect(page).to have_content(/#{Regexp.escape(pattern).gsub('N', '\d+')}/i)
      end
    end
  end
end

Then("no retention scores are shown") do
  within("[data-progress-dashboard]") do
    expect(page).not_to have_css("[data-retention-score]")
  end
end

Then("Lesson {int} shows its completion status but no retention score") do |lesson_number|
  within("[data-progress-dashboard]") do
    within("[data-lesson-id='#{lesson_number}']") do
      expect(page).to have_css("[data-lesson-status]")
      expect(page).not_to have_css("[data-retention-score]")
    end
  end
end

Then("no placeholder score (such as 0% or N/A) is shown as a retention score") do
  within("[data-progress-dashboard]") do
    expect(page).not_to have_css("[data-retention-score='0%']")
    expect(page).not_to have_content("N/A")
  end
end
