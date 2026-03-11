class DashboardController < ApplicationController
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

    mastered  = intervals.count { |i| i >= LessonStatusProjector::MASTERED_THRESHOLD }
    in_review = intervals.count { |i| i >= LessonStatusProjector::IN_REVIEW_THRESHOLD && i < LessonStatusProjector::MASTERED_THRESHOLD }
    new_count = intervals.count { |i| i < LessonStatusProjector::IN_REVIEW_THRESHOLD }

    { mastered: mastered, in_review: in_review, new: new_count }
  end

  def compute_lessons_fraction(user)
    total = Lesson.count
    return { completed: 0, total: total, percent: 0 } if total.zero?

    mastered_exercise_ids = Review
      .where(user_id: user.id)
      .where("sm2_interval >= ?", LessonStatusProjector::MASTERED_THRESHOLD)
      .pluck(:exercise_id)

    completed = Exercise
      .where(id: mastered_exercise_ids)
      .group(:lesson_id)
      .having("COUNT(*) = (SELECT COUNT(*) FROM exercises e2 WHERE e2.lesson_id = exercises.lesson_id)")
      .pluck(:lesson_id)
      .count

    percent = ((completed.to_f / total) * 100).round
    { completed: completed, total: total, percent: percent }
  end

  def account_age_days(user)
    (Time.current.to_date - user.created_at.to_date).to_i
  end
end
