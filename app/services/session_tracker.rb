class SessionTracker
  CAP_WARNING_SECONDS = 850
  CAP_REDIRECT_SECONDS = 900

  # Creates a new learning session row for the user
  def self.start(user)
    LearningSession.create!(
      user_id: user.id,
      started_at: Time.current,
      session_date: Date.current,
      exercises_completed: 0
    )
  end

  # Records an exercise completion, enforcing the 900s server-side cap.
  # Returns:
  #   :cap_warning  - elapsed >= 850s, exercise NOT persisted (show warning)
  #   :cap_redirect - elapsed >= 900s, exercise persisted, redirect to summary
  #   :ok           - normal case, exercise persisted
  def self.record_exercise(learning_session)
    elapsed = Time.current - learning_session.started_at

    if elapsed >= CAP_REDIRECT_SECONDS
      learning_session.increment!(:exercises_completed)
      :cap_redirect
    elsif elapsed >= CAP_WARNING_SECONDS
      :cap_warning
    else
      learning_session.increment!(:exercises_completed)
      :ok
    end
  end

  # Completes the session. Increments streak once per calendar day if exercises_completed >= 1.
  def self.complete(learning_session)
    user = learning_session.user
    return if learning_session.exercises_completed < 1

    today = Date.current
    return if user.last_session_date == today

    user.update!(
      streak_count: user.streak_count + 1,
      last_session_date: today
    )
  end
end
