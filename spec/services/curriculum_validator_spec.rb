require "rails_helper"

# Test Budget: 2 behaviors x 2 = 4 max unit tests
# Behavior 1: valid DAG (no cycles, all prereq IDs exist) → validate! does not raise
# Behavior 2: invalid DAG (cycle detected) → validate! raises error
# Behavior 3: invalid prerequisite ID (references non-existent lesson) → validate! raises error

RSpec.describe CurriculumValidator do
  # Helper to build lesson-like structs without hitting DB
  def make_lesson(id:, prerequisite_ids:)
    double("Lesson", id: id, title: "Lesson #{id}", prerequisite_ids: prerequisite_ids)
  end

  describe ".validate!" do
    # Behavior 1: valid DAG passes
    it "does not raise when lessons form a valid DAG with no cycles" do
      lessons = [
        make_lesson(id: 1, prerequisite_ids: []),
        make_lesson(id: 2, prerequisite_ids: [1]),
        make_lesson(id: 3, prerequisite_ids: [1, 2])
      ]
      expect { CurriculumValidator.validate!(lessons) }.not_to raise_error
    end

    # Behavior 1 variant: empty prerequisite_ids
    it "does not raise when all lessons have no prerequisites" do
      lessons = [
        make_lesson(id: 10, prerequisite_ids: []),
        make_lesson(id: 11, prerequisite_ids: []),
        make_lesson(id: 12, prerequisite_ids: [])
      ]
      expect { CurriculumValidator.validate!(lessons) }.not_to raise_error
    end

    # Behavior 2: cycle detection
    it "raises an error when a direct cycle exists between two lessons" do
      lessons = [
        make_lesson(id: 1, prerequisite_ids: [2]),
        make_lesson(id: 2, prerequisite_ids: [1])
      ]
      expect { CurriculumValidator.validate!(lessons) }.to raise_error(CurriculumValidator::CyclicDependencyError)
    end

    it "raises an error when an indirect cycle exists (A→B→C→A)" do
      lessons = [
        make_lesson(id: 1, prerequisite_ids: [3]),
        make_lesson(id: 2, prerequisite_ids: [1]),
        make_lesson(id: 3, prerequisite_ids: [2])
      ]
      expect { CurriculumValidator.validate!(lessons) }.to raise_error(CurriculumValidator::CyclicDependencyError)
    end

    # Behavior 3: invalid prerequisite ID
    it "raises an error when a lesson references a non-existent prerequisite ID" do
      lessons = [
        make_lesson(id: 1, prerequisite_ids: []),
        make_lesson(id: 2, prerequisite_ids: [99])
      ]
      expect { CurriculumValidator.validate!(lessons) }.to raise_error(CurriculumValidator::InvalidPrerequisiteError)
    end
  end
end
