class QueueBuilder
  MAX_QUEUE_SIZE = 20

  # Builds a daily review queue for the user.
  # Queries reviews with next_review_date <= date, ordered oldest-due first,
  # truncates to MAX_QUEUE_SIZE, then upserts into daily_queues idempotently.
  #
  # Returns the DailyQueue record.
  def self.build(user_id:, date:)
    exercise_ids = Review
      .where(user_id: user_id)
      .where("next_review_date <= ?", date)
      .order(:next_review_date)
      .limit(MAX_QUEUE_SIZE)
      .pluck(:exercise_id)

    upsert(user_id: user_id, date: date, exercise_ids: exercise_ids)
  end

  def self.upsert(user_id:, date:, exercise_ids:)
    sql = <<~SQL
      INSERT INTO daily_queues (user_id, queue_date, exercise_ids, created_at, updated_at)
      VALUES ($1, $2, $3, NOW(), NOW())
      ON CONFLICT (user_id, queue_date)
      DO UPDATE SET exercise_ids = EXCLUDED.exercise_ids, updated_at = NOW()
      RETURNING id
    SQL

    result = ActiveRecord::Base.connection.exec_query(
      sql,
      "QueueBuilder Upsert",
      [user_id, date, exercise_ids.to_s.gsub("[", "{").gsub("]", "}")]
    )

    DailyQueue.find(result.rows.first.first)
  end
end
