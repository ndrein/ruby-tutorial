class LessonStatusProjector
  MASTERED_THRESHOLD = 30
  IN_REVIEW_THRESHOLD = 3

  # Derives lesson status for a user at read time — NEVER stored in DB.
  # Returns one of: :locked, :mastered, :in_review, :available, :new
  def self.project(lesson, user)
    return :locked unless PrerequisiteChecker.met?(lesson, user)

    exercises = lesson.exercises.to_a
    return :new if exercises.empty?

    intervals = intervals_for(lesson, user)

    return :new if intervals.empty?
    return :available if intervals.size < exercises.size

    min_interval = intervals.min

    if min_interval >= MASTERED_THRESHOLD
      :mastered
    elsif min_interval >= IN_REVIEW_THRESHOLD
      :in_review
    else
      :available
    end
  end

  def self.intervals_for(lesson, user)
    Review
      .joins(:exercise)
      .where(exercises: { lesson_id: lesson.id }, user_id: user.id)
      .pluck(:sm2_interval)
  end
  private_class_method :intervals_for
end
