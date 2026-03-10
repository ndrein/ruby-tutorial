require "rails_helper"

RSpec.describe "Database schema", type: :request do
  let(:connection) { ActiveRecord::Base.connection }

  describe "all 7 tables exist with correct structure" do
    let(:tables) { connection.tables }

    it "has all 7 required tables" do
      expect(tables).to include("users", "modules", "lessons", "exercises",
                                "reviews", "sessions", "daily_queues")
    end

    it "users table has required columns" do
      columns = connection.columns("users").map(&:name)
      expect(columns).to include("id", "email", "experience_level",
                                 "password_digest", "streak_count",
                                 "last_session_date", "email_opted_in",
                                 "email_delivery_hour", "timezone",
                                 "created_at", "updated_at")
    end

    it "reviews table has sm2 columns" do
      columns = connection.columns("reviews").map(&:name)
      expect(columns).to include("sm2_ease_factor", "sm2_interval",
                                 "repetitions", "next_review_date",
                                 "answer_result", "quality_score")
    end

    it "daily_queues table has required columns" do
      columns = connection.columns("daily_queues").map(&:name)
      expect(columns).to include("user_id", "queue_date", "exercise_ids",
                                 "email_sent_at")
    end
  end

  describe "unique constraints" do
    it "reviews has UNIQUE constraint on (user_id, exercise_id)" do
      indexes = connection.indexes("reviews")
      unique_index = indexes.find do |idx|
        idx.unique && idx.columns.sort == %w[exercise_id user_id]
      end
      expect(unique_index).not_to be_nil
    end

    it "daily_queues has UNIQUE constraint on (user_id, queue_date)" do
      indexes = connection.indexes("daily_queues")
      unique_index = indexes.find do |idx|
        idx.unique && idx.columns.sort == %w[queue_date user_id]
      end
      expect(unique_index).not_to be_nil
    end
  end

  describe "CHECK constraints on reviews" do
    it "has sm2_ease_factor CHECK constraint" do
      check_constraints = connection.check_constraints("reviews")
      ease_factor_check = check_constraints.find { |c| c.name == "chk_reviews_sm2_ease_factor" }
      expect(ease_factor_check).not_to be_nil
      expect(ease_factor_check.expression).to include("1.30")
      expect(ease_factor_check.expression).to include("2.50")
    end

    it "has sm2_interval CHECK constraint >= 1" do
      check_constraints = connection.check_constraints("reviews")
      interval_check = check_constraints.find { |c| c.name == "chk_reviews_sm2_interval" }
      expect(interval_check).not_to be_nil
      expect(interval_check.expression).to include("1")
    end
  end

  describe "schema loadable from scratch" do
    it "schema version is set" do
      version = ActiveRecord::SchemaMigration.new(ActiveRecord::Base.connection_pool).versions.map(&:to_i).max
      expect(version).to eq(7)
    end
  end
end
