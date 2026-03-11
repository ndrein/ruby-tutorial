class DailyQueueMailer < ApplicationMailer
  MINUTES_PER_REVIEW    = 2
  MAX_SESSION_MINUTES   = 60
  MIN_SESSION_MINUTES   = 1

  def daily_digest(user, daily_queue)
    @user = user
    @daily_queue = daily_queue
    @review_count = daily_queue.exercise_ids.size
    @time_estimate_minutes = (@review_count * MINUTES_PER_REVIEW).clamp(MIN_SESSION_MINUTES, MAX_SESSION_MINUTES)
    @session_url = new_session_url(host: default_url_options[:host] || "localhost:3000")

    mail(
      to: user.email,
      subject: "#{@review_count} review#{"s" if @review_count != 1} ready — #{@time_estimate_minutes} min session"
    )
  end
end
