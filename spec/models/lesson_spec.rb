require "rails_helper"

RSpec.describe Lesson, type: :model do
  subject(:lesson) do
    described_class.new(
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

  let(:course_module) { CourseModule.create!(title: "Ruby Fundamentals for Polyglots", position: 1) }

  # Behavior 1: valid lesson with all required fields
  it "is valid with all required fields" do
    expect(lesson).to be_valid
  end

  # Behavior 2: invalid lesson without title
  it "is invalid without a title" do
    lesson.title = nil
    expect(lesson).not_to be_valid
    expect(lesson.errors[:title]).to be_present
  end
end
