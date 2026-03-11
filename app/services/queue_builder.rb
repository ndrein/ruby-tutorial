class QueueBuilder
  MAX_QUEUE_SIZE = 20

  UPSERT_SQL = <<~SQL.freeze
    INSERT INTO daily_queues (user_id, queue_date, exercise_ids, created_at, updated_at)
    VALUES ($1, $2, $3, NOW(), NOW())
    ON CONFLICT (user_id, queue_date)
    DO UPDATE SET exercise_ids = EXCLUDED.exercise_ids, updated_at = NOW()
    RETURNING id
  SQL

  def self.build(user_id:, date:)
    exercise_ids = due_exercise_ids(user_id: user_id, date: date)
    upsert(user_id: user_id, date: date, exercise_ids: exercise_ids)
  end

  def self.upsert(user_id:, date:, exercise_ids:)
    result = ActiveRecord::Base.connection.exec_query(
      UPSERT_SQL,
      "QueueBuilder Upsert",
      [user_id, date, to_postgres_array(exercise_ids)]
    )

    DailyQueue.find(result.rows.first.first)
  end

  def self.due_exercise_ids(user_id:, date:)
    Review
      .where(user_id: user_id)
      .where("next_review_date <= ?", date)
      .order(:next_review_date)
      .limit(MAX_QUEUE_SIZE)
      .pluck(:exercise_id)
  end
  private_class_method :due_exercise_ids

  def self.to_postgres_array(ruby_array)
    raise ArgumentError, "exercise_ids must be integers" unless ruby_array.all? { |id| id.is_a?(Integer) }
    "{#{ruby_array.join(',')}}"
  end
  private_class_method :to_postgres_array
end
