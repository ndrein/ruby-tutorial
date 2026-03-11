class QueueBuilderJob < ApplicationJob
  queue_as :default

  def perform
    today = Date.current
    User.where(email_opted_in: true).find_each do |user|
      QueueBuilder.build(user_id: user.id, date: today)
    end
  end
end
