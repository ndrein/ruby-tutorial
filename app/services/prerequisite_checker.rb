class PrerequisiteChecker
  # Returns true if all prerequisite lessons for the given lesson
  # have at least one review record for the given user.
  # Status is NEVER stored — always derived at read time.
  def self.met?(lesson, user)
    return true if lesson.prerequisite_ids.empty?

    reviewed_lesson_ids = reviewed_lesson_ids_for(user)
    lesson.prerequisite_ids.all? { |prereq_id| reviewed_lesson_ids.include?(prereq_id) }
  end

  def self.reviewed_lesson_ids_for(user)
    Exercise
      .joins(:reviews)
      .where(reviews: { user_id: user.id })
      .distinct
      .pluck(:lesson_id)
  end
  private_class_method :reviewed_lesson_ids_for
end
