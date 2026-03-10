class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.uuid :user_id, null: false
      t.integer :exercise_id, null: false
      t.integer :sm2_interval, null: false, default: 1
      t.decimal :sm2_ease_factor, precision: 4, scale: 2, null: false, default: "2.50"
      t.integer :repetitions, null: false, default: 0
      t.date :next_review_date, null: false
      t.string :answer_result, limit: 20, null: false
      t.integer :quality_score, null: false, default: 0

      t.datetime :reviewed_at, precision: 6
      t.datetime :created_at, null: false, precision: 6, default: -> { "NOW()" }
      t.datetime :updated_at, null: false, precision: 6, default: -> { "NOW()" }
    end

    add_foreign_key :reviews, :users, on_delete: :cascade
    add_foreign_key :reviews, :exercises
    add_index :reviews, [:user_id, :exercise_id], unique: true
    add_index :reviews, [:user_id, :next_review_date]

    execute <<~SQL
      ALTER TABLE reviews
        ADD CONSTRAINT chk_reviews_sm2_interval
          CHECK (sm2_interval >= 1),
        ADD CONSTRAINT chk_reviews_sm2_ease_factor
          CHECK (sm2_ease_factor >= 1.30 AND sm2_ease_factor <= 2.50),
        ADD CONSTRAINT chk_reviews_repetitions
          CHECK (repetitions >= 0),
        ADD CONSTRAINT chk_reviews_answer_result
          CHECK (answer_result IN ('correct', 'incorrect', 'skipped', 'timeout')),
        ADD CONSTRAINT chk_reviews_quality_score
          CHECK (quality_score BETWEEN 0 AND 5);
    SQL
  end
end
