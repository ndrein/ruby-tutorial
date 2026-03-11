class CurriculumController < ApplicationController
  def index
    @user = current_user
    @modules = CourseModule.includes(lessons: :exercises).order(:position)
    @lesson_statuses = build_lesson_statuses(@modules, @user)
    @prerequisite_titles = build_prerequisite_titles(@modules)
  end

  private

  def current_user
    @current_user ||= User.first
  end

  def build_lesson_statuses(modules, user)
    statuses = {}
    modules.each do |mod|
      mod.lessons.each do |lesson|
        statuses[lesson.id] = LessonStatusProjector.project(lesson, user)
      end
    end
    statuses
  end

  def build_prerequisite_titles(modules)
    all_lessons = modules.flat_map(&:lessons).index_by(&:id)
    titles = {}
    all_lessons.each_value do |lesson|
      if lesson.prerequisite_ids.any?
        titles[lesson.id] = lesson.prerequisite_ids.filter_map do |prereq_id|
          all_lessons[prereq_id]&.title
        end
      end
    end
    titles
  end
end
