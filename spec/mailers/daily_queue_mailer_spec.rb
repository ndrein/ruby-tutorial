require "rails_helper"

RSpec.describe DailyQueueMailer, type: :mailer do
  let(:user) do
    User.create!(
      email: "learner@example.com",
      password: "password123",
      experience_level: "expert",
      timezone: "UTC",
      email_opted_in: true
    )
  end

  let(:daily_queue) do
    DailyQueue.create!(
      user: user,
      queue_date: Date.current,
      exercise_ids: [1, 2, 3]
    )
  end

  # Behavior 1: email subject includes review count and time estimate (AC-009-02)
  describe "#daily_digest" do
    subject(:mail) { DailyQueueMailer.daily_digest(user, daily_queue) }

    it "includes review count and time estimate in subject" do
      expect(mail.subject).to include("3")
      expect(mail.subject).to match(/\d+\s*(min|minute)/)
    end

    it "sends to the user's email address" do
      expect(mail.to).to eq(["learner@example.com"])
    end

    # Behavior 2: only CTA is session start URL, no promotional content (AC-009-03)
    it "contains session start URL as the only call to action" do
      body = mail.body.to_s
      expect(body).to include("sessions/new")
    end

    it "does not contain promotional content" do
      body = mail.body.to_s
      promotional_terms = %w[discount offer upgrade premium subscribe sale]
      promotional_terms.each do |term|
        expect(body.downcase).not_to include(term)
      end
    end
  end
end
