# Load seed component files
load Rails.root.join("db/seeds/module_definitions.rb")
load Rails.root.join("db/seeds/lesson_definitions.rb")
load Rails.root.join("db/seeds/exercise_definitions.rb")

# ── Modules ──────────────────────────────────────────────────────────
MODULE_DEFINITIONS.each do |attrs|
  CourseModule.find_or_create_by!(position: attrs[:position]) do |m|
    m.id    = attrs[:id]
    m.title = attrs[:title]
  end
end

# Build lesson ID → database ID mapping (handles cases where DB assigns different IDs)
lesson_db_ids = {}

# ── Lessons ───────────────────────────────────────────────────────────
LESSON_DEFINITIONS.each do |attrs|
  mod = CourseModule.find_by!(position: attrs[:module_id]) # module_id in def = module position
  lesson = Lesson.find_or_create_by!(
    module_id:         mod.id,
    position_in_module: attrs[:position_in_module]
  ) do |l|
    l.title             = attrs[:title]
    l.content_body      = attrs[:content_body]
    l.python_equivalent = attrs[:python_equivalent]
    l.java_equivalent   = attrs[:java_equivalent]
    l.estimated_minutes = attrs[:estimated_minutes]
    l.prerequisite_ids  = [] # resolved after all lessons created
  end
  lesson_db_ids[attrs[:id]] = lesson.id
end

# Resolve prerequisite_ids: replace definition IDs with DB IDs
LESSON_DEFINITIONS.each do |attrs|
  mod = CourseModule.find_by!(position: attrs[:module_id])
  lesson = Lesson.find_by!(module_id: mod.id, position_in_module: attrs[:position_in_module])
  resolved_prereqs = attrs[:prerequisite_ids].map { |def_id| lesson_db_ids[def_id] }.compact
  lesson.update!(prerequisite_ids: resolved_prereqs)
end

# ── Exercises ─────────────────────────────────────────────────────────
EXERCISE_DEFINITIONS.each do |attrs|
  lesson_def_id = attrs[:lesson_id]
  db_lesson_id  = lesson_db_ids[lesson_def_id]
  raise "No DB lesson ID found for definition lesson_id=#{lesson_def_id}" if db_lesson_id.nil?

  Exercise.find_or_create_by!(lesson_id: db_lesson_id, position: attrs[:position]) do |e|
    e.exercise_type   = attrs[:exercise_type]
    e.prompt          = attrs[:prompt]
    e.correct_answer  = attrs[:correct_answer]
    e.accepted_synonyms = attrs[:accepted_synonyms]
    e.options         = attrs[:options]
    e.explanation     = attrs[:explanation]
  end
end

# ── DAG Validation ────────────────────────────────────────────────────
CurriculumValidator.validate!(Lesson.all.to_a)

puts "Seed complete: #{CourseModule.count} modules, #{Lesson.count} lessons, #{Exercise.count} exercises"

# Keep test user for development only
unless Rails.env.test?
  User.create!(
    email: "test@example.com",
    password: "password123",
    experience_level: "expert",
    timezone: "UTC"
  ) unless User.exists?(email: "test@example.com")
end
