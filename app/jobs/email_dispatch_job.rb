class EmailDispatchJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 15.minutes, attempts: 2

  def perform(user_id)
    user = User.find(user_id)
    daily_queue = DailyQueue.find_by(user: user, queue_date: Date.current)

    return if daily_queue.nil?
    return if daily_queue.exercise_ids.empty?
    return if daily_queue.email_sent_at.present?

    begin
      DailyQueueMailer.daily_digest(user, daily_queue).deliver_now
      daily_queue.update!(email_sent_at: Time.current)
    rescue => e
      Rails.logger.error("[EmailDispatchJob] Delivery failed for user_id=#{user_id} at #{Time.current}: #{e.message}")
      raise
    end
  end
end
