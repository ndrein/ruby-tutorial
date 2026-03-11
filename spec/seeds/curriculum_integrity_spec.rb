require "rails_helper"

# Acceptance tests for seed data integrity
# These tests run seeds in-process and verify:
# AC1: 5 modules, 25 lessons with correct module association and unique position_in_module
# AC2: content_body, python_equivalent, java_equivalent non-empty and no beginner phrases
# AC3: all 4 exercise types present, each lesson has >= 1 exercise, multiple_choice has exactly 4 options
# AC4: Ruby code examples in content_body are syntactically valid
# AC5: prerequisite DAG is valid (CurriculumValidator passes)

RSpec.describe "Curriculum seed data integrity", type: :model do
  before(:all) do
    # Clean curriculum data and re-seed
    Exercise.delete_all
    Lesson.delete_all
    CourseModule.delete_all
    load Rails.root.join("db/seeds.rb")
  end

  after(:all) do
    Exercise.delete_all
    Lesson.delete_all
    CourseModule.delete_all
  end

  # AC1: module and lesson counts
  describe "module and lesson counts" do
    it "seeds exactly 5 modules" do
      expect(CourseModule.count).to eq(5)
    end

    it "seeds exactly 25 lessons" do
      expect(Lesson.count).to eq(25)
    end

    it "each module has exactly 5 lessons" do
      CourseModule.all.each do |mod|
        expect(mod.lessons.count).to eq(5),
          "Module '#{mod.title}' has #{mod.lessons.count} lessons, expected 5"
      end
    end

    it "each module has unique position_in_module values 1..5" do
      CourseModule.all.each do |mod|
        positions = mod.lessons.pluck(:position_in_module).sort
        expect(positions).to eq([1, 2, 3, 4, 5]),
          "Module '#{mod.title}' has positions #{positions}"
      end
    end
  end

  # AC2: content quality - no beginner phrases
  describe "lesson content quality" do
    BEGINNER_PHRASES = [
      "In programming, ",
      "A variable is ",
      "Let's start with the basics"
    ].freeze

    it "all lessons have non-empty content_body" do
      Lesson.all.each do |lesson|
        expect(lesson.content_body).to be_present,
          "Lesson '#{lesson.title}' has empty content_body"
      end
    end

    it "all lessons have non-empty python_equivalent" do
      Lesson.all.each do |lesson|
        expect(lesson.python_equivalent).to be_present,
          "Lesson '#{lesson.title}' has empty python_equivalent"
      end
    end

    it "all lessons have non-empty java_equivalent" do
      Lesson.all.each do |lesson|
        expect(lesson.java_equivalent).to be_present,
          "Lesson '#{lesson.title}' has empty java_equivalent"
      end
    end

    it "no lesson content_body contains beginner phrases" do
      Lesson.all.each do |lesson|
        BEGINNER_PHRASES.each do |phrase|
          expect(lesson.content_body).not_to include(phrase),
            "Lesson '#{lesson.title}' content_body contains beginner phrase: '#{phrase}'"
        end
      end
    end

    it "no lesson python_equivalent contains beginner phrases" do
      Lesson.all.each do |lesson|
        BEGINNER_PHRASES.each do |phrase|
          expect(lesson.python_equivalent).not_to include(phrase),
            "Lesson '#{lesson.title}' python_equivalent contains: '#{phrase}'"
        end
      end
    end

    it "no lesson java_equivalent contains beginner phrases" do
      Lesson.all.each do |lesson|
        BEGINNER_PHRASES.each do |phrase|
          expect(lesson.java_equivalent).not_to include(phrase),
            "Lesson '#{lesson.title}' java_equivalent contains: '#{phrase}'"
        end
      end
    end
  end

  # AC3: exercise coverage
  describe "exercise coverage" do
    it "every lesson has at least 1 exercise" do
      Lesson.all.each do |lesson|
        expect(lesson.exercises.count).to be >= 1,
          "Lesson '#{lesson.title}' has no exercises"
      end
    end

    it "all 4 exercise types are present across the curriculum" do
      types_present = Exercise.distinct.pluck(:exercise_type)
      expect(types_present).to include("fill_in_blank", "multiple_choice", "spot_the_bug", "translation")
    end

    it "all multiple_choice exercises have exactly 4 options" do
      Exercise.where(exercise_type: "multiple_choice").each do |ex|
        expect(ex.options.length).to eq(4),
          "Exercise id=#{ex.id} (lesson #{ex.lesson_id}) has #{ex.options.length} options"
      end
    end
  end

  # AC4: Ruby syntax validity
  describe "Ruby code example syntax validity" do
    it "all Ruby code blocks in content_body are syntactically valid" do
      Lesson.all.each do |lesson|
        # Extract ```ruby ... ``` code blocks
        code_blocks = lesson.content_body.scan(/```ruby\n(.*?)```/m).flatten
        code_blocks.each_with_index do |code, i|
          expect {
            RubyVM::AbstractSyntaxTree.parse(code)
          }.not_to raise_error,
            "Lesson '#{lesson.title}' ruby block #{i + 1} has syntax error:\n#{code}"
        end
      end
    end
  end

  # AC5: DAG integrity
  describe "prerequisite DAG integrity" do
    it "CurriculumValidator.validate! passes with seeded lesson data" do
      expect {
        CurriculumValidator.validate!(Lesson.all.to_a)
      }.not_to raise_error
    end
  end
end
