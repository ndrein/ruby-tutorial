require "rails_helper"

RSpec.describe EmailDispatchJob, type: :job do
  let(:user) do
    User.create!(
      email: "learner@example.com",
      password: "password123",
      experience_level: "expert",
      timezone: "UTC",
      email_opted_in: true
    )
  end

  # Behavior 4: dispatches email for non-empty queue with email_sent_at NULL (AC-2)
  describe "#perform" do
    context "when daily_queue has exercises and email_sent_at is nil" do
      let!(:daily_queue) do
        DailyQueue.create!(
          user: user,
          queue_date: Date.current,
          exercise_ids: [1, 2, 3],
          email_sent_at: nil
        )
      end

      it "dispatches one email via DailyQueueMailer" do
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        allow(message_delivery).to receive(:deliver_now)
        allow(DailyQueueMailer).to receive(:daily_digest).and_return(message_delivery)

        EmailDispatchJob.new.perform(user.id)

        expect(DailyQueueMailer).to have_received(:daily_digest).with(user, daily_queue)
        expect(message_delivery).to have_received(:deliver_now)
      end

      # Behavior 5: sets email_sent_at after dispatch (AC-3, NFR-2.4)
      it "sets email_sent_at on the daily_queue after dispatch" do
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        allow(message_delivery).to receive(:deliver_now)
        allow(DailyQueueMailer).to receive(:daily_digest).and_return(message_delivery)

        freeze_time = Time.current
        allow(Time).to receive(:current).and_return(freeze_time)

        EmailDispatchJob.new.perform(user.id)

        daily_queue.reload
        expect(daily_queue.email_sent_at).not_to be_nil
      end
    end

    # Behavior 6: does NOT send email when email_sent_at already set (AC-3 duplicate prevention)
    context "when email_sent_at is already set" do
      let!(:daily_queue) do
        DailyQueue.create!(
          user: user,
          queue_date: Date.current,
          exercise_ids: [1, 2, 3],
          email_sent_at: 1.hour.ago
        )
      end

      it "does not send a duplicate email" do
        allow(DailyQueueMailer).to receive(:daily_digest)

        EmailDispatchJob.new.perform(user.id)

        expect(DailyQueueMailer).not_to have_received(:daily_digest)
      end
    end

    # Behavior 7: does NOT send email when queue is empty (AC-4)
    context "when daily_queue has no exercises" do
      let!(:daily_queue) do
        DailyQueue.create!(
          user: user,
          queue_date: Date.current,
          exercise_ids: [],
          email_sent_at: nil
        )
      end

      it "does not send email for empty queue" do
        allow(DailyQueueMailer).to receive(:daily_digest)

        EmailDispatchJob.new.perform(user.id)

        expect(DailyQueueMailer).not_to have_received(:daily_digest)
      end
    end

    # Behavior 8: logs error and raises for retry when Postmark fails (AC-5)
    context "when Postmark returns a delivery error" do
      let!(:daily_queue) do
        DailyQueue.create!(
          user: user,
          queue_date: Date.current,
          exercise_ids: [1, 2, 3],
          email_sent_at: nil
        )
      end

      it "logs error with timestamp and user_id before re-raising" do
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        delivery_error = StandardError.new("Postmark delivery failed")
        allow(message_delivery).to receive(:deliver_now).and_raise(delivery_error)
        allow(DailyQueueMailer).to receive(:daily_digest).and_return(message_delivery)

        expect(Rails.logger).to receive(:error).with(
          a_string_including(user.id.to_s)
        )

        expect { EmailDispatchJob.new.perform(user.id) }.to raise_error(StandardError)
      end
    end
  end
end
