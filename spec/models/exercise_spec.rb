require "rails_helper"

RSpec.describe Exercise, type: :model do
  # Test Budget: 3 behaviors x 2 = 6 max unit tests (using 3)
  # Behavior 1: exact correct_answer match returns :correct
  # Behavior 2: accepted_synonyms match returns :correct
  # Behavior 3: non-matching answer returns :incorrect

  let(:course_module) { CourseModule.create!(title: "Ruby Fundamentals", position: 1) }

  let(:lesson) do
    Lesson.create!(
      module_id: course_module.id,
      title: "Ruby Blocks",
      position_in_module: 1,
      content_body: "Ruby blocks are anonymous functions.",
      python_equivalent: "Equivalent to Python lambda.",
      java_equivalent: "Similar to Java 8+ lambda expressions.",
      estimated_minutes: 5,
      prerequisite_ids: []
    )
  end

  subject(:exercise) do
    Exercise.create!(
      lesson_id: lesson.id,
      exercise_type: "fill_in_blank",
      prompt: "Complete: arr.____(){ |x| x > 3 }",
      correct_answer: "select",
      accepted_synonyms: [ "Array#select" ],
      explanation: "Array#select returns elements for which the block returns true.",
      options: [],
      position: 1
    )
  end

  describe "#evaluate_answer" do
    it "returns :correct when submitted answer matches correct_answer exactly" do
      expect(exercise.evaluate_answer("select")).to eq(:correct)
    end

    it "returns :correct when submitted answer matches an accepted synonym" do
      expect(exercise.evaluate_answer("Array#select")).to eq(:correct)
    end

    it "returns :incorrect when submitted answer does not match correct_answer or synonyms" do
      expect(exercise.evaluate_answer("wrong")).to eq(:incorrect)
    end
  end
end
