require "rails_helper"

RSpec.describe "Walking Skeleton", type: :request do
  describe "GET /" do
    it "returns HTTP 200" do
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /lessons/:id" do
    it "returns HTTP 200 with lesson title in body" do
      lesson = Lesson.find_or_create_by!(id: 1) do |l|
        module_record = CourseModule.find_or_create_by!(id: 1) do |m|
          m.title = "Ruby Fundamentals for Polyglots"
          m.position = 1
        end
        l.module_id = module_record.id
        l.title = "Ruby Blocks"
        l.position_in_module = 1
        l.content_body = "Ruby blocks are anonymous functions passed to methods using do...end or {}."
        l.python_equivalent = "Equivalent to Python lambda or passing a function as argument"
        l.java_equivalent = "Similar to Java 8+ lambda expressions or anonymous Runnable implementations"
        l.estimated_minutes = 5
        l.prerequisite_ids = []
      end

      get lesson_path(lesson)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ruby Blocks")
    end
  end

  describe "GET /exercises/:id" do
    it "returns HTTP 200 with answer input field" do
      module_record = CourseModule.find_or_create_by!(id: 1) do |m|
        m.title = "Ruby Fundamentals for Polyglots"
        m.position = 1
      end
      lesson = Lesson.find_or_create_by!(id: 1) do |l|
        l.module_id = module_record.id
        l.title = "Ruby Blocks"
        l.position_in_module = 1
        l.content_body = "Ruby blocks are anonymous functions passed to methods using do...end or {}."
        l.python_equivalent = "Equivalent to Python lambda or passing a function as argument"
        l.java_equivalent = "Similar to Java 8+ lambda expressions or anonymous Runnable implementations"
        l.estimated_minutes = 5
        l.prerequisite_ids = []
      end
      exercise = Exercise.find_or_create_by!(id: 1) do |e|
        e.lesson_id = lesson.id
        e.exercise_type = "fill_in_blank"
        e.prompt = "Complete: arr.____(){ |x| x > 3 }"
        e.correct_answer = "select"
        e.accepted_synonyms = ["Array#select"]
        e.explanation = "Array#select returns elements for which the block returns true."
        e.options = []
        e.position = 1
      end

      get exercise_path(exercise)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('input')
    end
  end
end
