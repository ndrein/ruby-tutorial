require "rails_helper"

RSpec.describe QueueBuilderJob, type: :job do
  # Behavior 3: QueueBuilderJob calls QueueBuilder for all opted-in users (AC-1)
  describe "#perform" do
    let!(:opted_in_user) do
      User.create!(
        email: "opted_in@example.com",
        password: "password123",
        experience_level: "expert",
        timezone: "UTC",
        email_opted_in: true
      )
    end

    let!(:opted_out_user) do
      User.create!(
        email: "opted_out@example.com",
        password: "password123",
        experience_level: "expert",
        timezone: "UTC",
        email_opted_in: false
      )
    end

    it "upserts daily_queues for all opted-in users and not opted-out users" do
      allow(QueueBuilder).to receive(:build).and_return(
        instance_double(DailyQueue, id: 1)
      )

      QueueBuilderJob.new.perform

      expect(QueueBuilder).to have_received(:build).with(
        user_id: opted_in_user.id,
        date: Date.current
      )
      expect(QueueBuilder).not_to have_received(:build).with(
        hash_including(user_id: opted_out_user.id)
      )
    end

    it "completes without error for opted-in users" do
      allow(QueueBuilder).to receive(:build).and_return(
        instance_double(DailyQueue, id: 1)
      )

      expect { QueueBuilderJob.new.perform }.not_to raise_error
    end
  end
end
