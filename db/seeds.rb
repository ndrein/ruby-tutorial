# This file should ensure the existence of records required to run the application in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# 1 module
learning_module = CourseModule.find_or_create_by!(id: 1) do |m|
  m.title = "Ruby Fundamentals for Polyglots"
  m.position = 1
end

# 1 lesson
lesson = Lesson.find_or_create_by!(id: 1) do |l|
  l.module_id = learning_module.id
  l.title = "Ruby Blocks"
  l.position_in_module = 1
  l.content_body = "Ruby blocks are anonymous functions passed to methods using do...end or {}..."
  l.python_equivalent = "Equivalent to Python lambda or passing a function as argument"
  l.java_equivalent = "Similar to Java 8+ lambda expressions or anonymous Runnable implementations"
  l.estimated_minutes = 5
  l.prerequisite_ids = []
end

# 1 exercise
Exercise.find_or_create_by!(id: 1) do |e|
  e.lesson_id = lesson.id
  e.exercise_type = "fill_in_blank"
  e.prompt = "Complete: arr.____(){ |x| x > 3 }"
  e.correct_answer = "select"
  e.accepted_synonyms = ["Array#select"]
  e.explanation = "Array#select (also called filter) returns elements for which the block returns true. Python equivalent: list comprehension [x for x in arr if x > 3]. Java equivalent: stream.filter(x -> x > 3)."
  e.options = []
  e.position = 1
end

# 1 user (test user for development)
User.create!(
  email: "test@example.com",
  password: "password123",
  experience_level: "expert",
  timezone: "UTC"
) unless User.exists?(email: "test@example.com")
