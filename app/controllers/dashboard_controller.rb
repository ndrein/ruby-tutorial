class DashboardController < ApplicationController
  MASTERED_THRESHOLD = 30
  IN_REVIEW_MIN = 3
  RETENTION_WINDOW_DAYS = 14

  def index
    @user = current_user
    @mastery_counts = compute_mastery_counts(@user)
    @lessons_fraction = compute_lessons_fraction(@user)
    @streak = @user.streak_count
    @retention_available = account_age_days(@user) >= RETENTION_WINDOW_DAYS
  end

  private

  def current_user
    @current_user ||= User.first
  end

  def compute_mastery_counts(user)
    intervals = Review.where(user_id: user.id).pluck(:sm2_interval)

    mastered = intervals.count { |i| i >= MASTERED_THRESHOLD }
    in_review = intervals.count { |i| i >= IN_REVIEW_MIN && i < MASTERED_THRESHOLD }
    new_count = intervals.count { |i| i < IN_REVIEW_MIN }

    { mastered: mastered, in_review: in_review, new: new_count }
  end

  def compute_lessons_fraction(user)
    total = Lesson.count
    return { completed: 0, total: total, percent: 0 } if total.zero?

    # A lesson is completed when ALL its exercises have a review with sm2_interval >= MASTERED_THRESHOLD
    reviewed_exercise_ids = Review
      .where(user_id: user.id)
      .where("sm2_interval >= ?", MASTERED_THRESHOLD)
      .pluck(:exercise_id)

    lesson_ids_with_all_mastered = Exercise
      .where(id: reviewed_exercise_ids)
      .group(:lesson_id)
      .having("COUNT(*) = (SELECT COUNT(*) FROM exercises e2 WHERE e2.lesson_id = exercises.lesson_id)")
      .pluck(:lesson_id)
      .count

    # Also check that lessons with no exercises are not counted as completed
    completed = lesson_ids_with_all_mastered

    percent = ((completed.to_f / total) * 100).round
    { completed: completed, total: total, percent: percent }
  end

  def account_age_days(user)
    (Time.current.to_date - user.created_at.to_date).to_i
  end
end
