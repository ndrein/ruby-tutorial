require "rails_helper"

# Test Budget: 5 distinct behaviors x 2 = 10 max unit tests
# Behavior 1: start creates sessions row with started_at=NOW() and exercises_completed=0
# Behavior 2: record_exercise at elapsed >= 850s returns cap-warning signal (no new exercise)
# Behavior 3: record_exercise at elapsed >= 900s persists answer and returns redirect signal
# Behavior 4: complete with exercises_completed >= 1 (first session today) increments streak + sets last_session_date
# Behavior 5: complete on same calendar day as last_session_date does not increment streak again

RSpec.describe SessionTracker do
  let!(:user) do
    User.create!(
      email: "tracker_test@example.com",
      password: "password123",
      experience_level: "expert",
      timezone: "UTC",
      streak_count: 0,
      last_session_date: nil
    )
  end

  # Behavior 1: start creates sessions row
  describe ".start" do
    it "creates a sessions row with started_at set and exercises_completed=0" do
      expect {
        SessionTracker.start(user)
      }.to change(LearningSession, :count).by(1)

      session = LearningSession.last
      expect(session.user_id).to eq(user.id)
      expect(session.exercises_completed).to eq(0)
      expect(session.started_at).to be_within(5.seconds).of(Time.current)
      expect(session.session_date).to eq(Date.current)
    end
  end

  # Behavior 2: cap-warning at elapsed >= 850s
  describe ".record_exercise" do
    let(:learning_session) { SessionTracker.start(user) }

    context "when elapsed >= 850 seconds and < 900 seconds" do
      it "returns :cap_warning and does not increment exercises_completed" do
        started_at = 855.seconds.ago
        learning_session.update!(started_at: started_at)

        result = SessionTracker.record_exercise(learning_session)

        expect(result).to eq(:cap_warning)
        expect(learning_session.reload.exercises_completed).to eq(0)
      end
    end

    # Behavior 3: hard redirect at elapsed >= 900s, answer still persisted (exercises_completed incremented)
    context "when elapsed >= 900 seconds" do
      it "increments exercises_completed and returns :cap_redirect" do
        started_at = 905.seconds.ago
        learning_session.update!(started_at: started_at)

        result = SessionTracker.record_exercise(learning_session)

        expect(result).to eq(:cap_redirect)
        expect(learning_session.reload.exercises_completed).to eq(1)
      end
    end

    context "when elapsed < 850 seconds" do
      it "increments exercises_completed and returns :ok" do
        started_at = 100.seconds.ago
        learning_session.update!(started_at: started_at)

        result = SessionTracker.record_exercise(learning_session)

        expect(result).to eq(:ok)
        expect(learning_session.reload.exercises_completed).to eq(1)
      end
    end
  end

  # Behavior 4: complete increments streak for first session today
  describe ".complete" do
    context "when user completes first session today with exercises_completed >= 1" do
      it "increments streak_count by 1 and sets last_session_date to today" do
        learning_session = SessionTracker.start(user)
        learning_session.update!(exercises_completed: 3)

        SessionTracker.complete(learning_session)

        user.reload
        expect(user.streak_count).to eq(1)
        expect(user.last_session_date).to eq(Date.current)
      end
    end

    context "when exercises_completed is 0" do
      it "does not increment streak_count" do
        learning_session = SessionTracker.start(user)
        # exercises_completed stays 0

        SessionTracker.complete(learning_session)

        user.reload
        expect(user.streak_count).to eq(0)
        expect(user.last_session_date).to be_nil
      end
    end

    # Behavior 5: no double-increment on same calendar day
    context "when user already completed a session today (last_session_date = today)" do
      it "does not increment streak_count again" do
        user.update!(streak_count: 2, last_session_date: Date.current)
        learning_session = SessionTracker.start(user)
        learning_session.update!(exercises_completed: 2)

        SessionTracker.complete(learning_session)

        user.reload
        expect(user.streak_count).to eq(2)
        expect(user.last_session_date).to eq(Date.current)
      end
    end
  end
end
