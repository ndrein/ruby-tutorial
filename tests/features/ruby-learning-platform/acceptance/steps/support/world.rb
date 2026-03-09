# World module — shared helpers and domain service accessors for step definitions.
#
# Mixed into the Cucumber World object, making these methods available in all
# step definitions. Methods speak business language; they delegate to production
# domain services through their driving ports (application services / controllers).
#
# Architecture note: step definitions call application services, not repositories
# or domain internals. This enforces the hexagonal boundary (CM-A compliance).

module RubyLearningPlatformWorld
  # ---- Session Services ----

  # Returns the SessionPlanner application service.
  # Steps use this to set up session state and verify plan computation.
  def session_planner
    @session_planner ||= SessionPlanner.new(
      review_repository: test_review_repository,
      lesson_repository: test_lesson_repository,
      session_repository: test_session_repository
    )
  end

  # Returns the current session plan for inspection in Then steps.
  def current_session_plan
    @current_session_plan
  end

  # ---- Review Services ----

  # Returns the ReviewScheduler application service.
  # Steps use this to record exercise results and verify SM-2 state updates.
  def review_scheduler
    @review_scheduler ||= ReviewScheduler.new(
      review_repository: test_review_repository
    )
  end

  # Returns the ReviewQueue domain service.
  # Steps use this to verify queue contents and ordering.
  def review_queue
    @review_queue ||= ReviewQueue.new(
      review_repository: test_review_repository
    )
  end

  # ---- Curriculum Services ----

  # Returns the CurriculumMap domain service.
  # Steps use this to query lesson status and tree structure.
  def curriculum_map
    @curriculum_map ||= CurriculumMap.new(
      lesson_repository: test_lesson_repository,
      prerequisite_graph: prerequisite_graph
    )
  end

  # Returns the LessonUnlocker domain service.
  # Steps verify atomic unlock behavior through this service.
  def lesson_unlocker
    @lesson_unlocker ||= LessonUnlocker.new(
      lesson_repository: test_lesson_repository,
      prerequisite_graph: prerequisite_graph
    )
  end

  # Returns the LockScreenPolicy domain service.
  # Steps verify lock screen content through this service.
  def lock_screen_policy
    @lock_screen_policy ||= LockScreenPolicy.new(
      lesson_repository: test_lesson_repository,
      prerequisite_graph: prerequisite_graph
    )
  end

  # Returns the loaded PrerequisiteGraph.
  def prerequisite_graph
    @prerequisite_graph ||= PrerequisiteGraph.load_from_file(
      Rails.root.join("db/curriculum/prerequisites.yml")
    )
  end

  # ---- Progress Services ----

  # Returns the ProgressDashboard application service.
  # Steps verify progress metrics through this service.
  def progress_dashboard
    @progress_dashboard ||= ProgressDashboard.new(
      review_repository: test_review_repository,
      lesson_repository: test_lesson_repository,
      session_repository: test_session_repository
    )
  end

  # ---- Exercise Services ----

  # Returns the AnswerEvaluator domain service.
  # Steps verify exercise evaluation through this service.
  def answer_evaluator
    @answer_evaluator ||= AnswerEvaluator.new
  end

  # ---- Shared Test State ----

  # Exercise result from the most recent answer submission.
  def last_exercise_result
    @last_exercise_result
  end

  # SM-2 state after the most recent update.
  def last_sm2_state
    @last_sm2_state
  end

  # The lesson currently in scope for a scenario.
  def current_lesson
    @current_lesson
  end

  # The exercise currently in scope for a scenario.
  def current_exercise
    @current_exercise
  end

  # ---- Repository Accessors (production repositories for acceptance tests) ----
  # Acceptance tests use real ActiveRecord repositories backed by the test database.
  # No in-memory fakes at this level — acceptance tests exercise the full stack.

  def test_review_repository
    @test_review_repository ||= Adapters::Repositories::ActiveRecord::ReviewRepository.new
  end

  def test_lesson_repository
    @test_lesson_repository ||= Adapters::Repositories::ActiveRecord::LessonRepository.new
  end

  def test_session_repository
    @test_session_repository ||= Adapters::Repositories::Redis::SessionRepository.new
  end

  # ---- Capybara Browser Helpers ----

  # Navigate to the platform's root (onboarding / session dashboard).
  def open_platform
    visit "/"
  end

  # Navigate to the curriculum tree view.
  def open_curriculum_tree
    visit "/curriculum"
  end

  # Navigate to the progress dashboard.
  def open_progress_dashboard
    visit "/progress"
  end

  # Press a keyboard shortcut key in the browser.
  # Used in step definitions for keyboard navigation scenarios.
  def press_key(key)
    find("body").send_keys(key)
  end

  # Navigate to a specific lesson by its number.
  def open_lesson(lesson_number)
    visit "/lessons/#{lesson_number}"
  end

  # Submit an answer to the current exercise.
  def submit_answer(answer_text)
    fill_in "answer", with: answer_text
    press_key(:enter)
  end

  # Take a screenshot for debugging (only when Capybara JS driver is active).
  def take_screenshot
    filename = "tmp/screenshots/#{Time.now.to_i}.png"
    page.save_screenshot(filename)
  end
end

World(RubyLearningPlatformWorld)
