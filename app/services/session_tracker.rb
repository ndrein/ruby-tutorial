class SessionTracker
  CAP_WARNING_SECONDS  = 850
  CAP_REDIRECT_SECONDS = 900

  def self.start(user)
    LearningSession.create!(
      user_id: user.id,
      started_at: Time.current,
      session_date: Date.current,
      exercises_completed: 0
    )
  end

  def self.record_exercise(learning_session)
    elapsed_seconds = elapsed_since_start(learning_session)

    if elapsed_seconds >= CAP_REDIRECT_SECONDS
      learning_session.increment!(:exercises_completed)
      :cap_redirect
    elsif elapsed_seconds >= CAP_WARNING_SECONDS
      :cap_warning
    else
      learning_session.increment!(:exercises_completed)
      :ok
    end
  end

  def self.complete(learning_session)
    return unless session_qualifies_for_streak?(learning_session)

    user = learning_session.user
    return if already_credited_today?(user)

    user.update!(
      streak_count: user.streak_count + 1,
      last_session_date: Date.current
    )
  end

  def self.elapsed_since_start(learning_session)
    Time.current - learning_session.started_at
  end
  private_class_method :elapsed_since_start

  def self.session_qualifies_for_streak?(learning_session)
    learning_session.exercises_completed >= 1
  end
  private_class_method :session_qualifies_for_streak?

  def self.already_credited_today?(user)
    user.last_session_date == Date.current
  end
  private_class_method :already_credited_today?
end
