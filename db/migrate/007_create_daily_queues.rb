class CreateDailyQueues < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_queues do |t|
      t.uuid :user_id, null: false
      t.date :queue_date, null: false
      t.integer :exercise_ids, array: true, null: false, default: []
      t.datetime :email_sent_at, precision: 6

      t.timestamps null: false, default: -> { "NOW()" }
    end

    add_foreign_key :daily_queues, :users, on_delete: :cascade
    add_index :daily_queues, [:user_id, :queue_date], unique: true
    add_index :daily_queues, :user_id, where: "email_sent_at IS NULL",
              name: "idx_daily_queues_unsent"
  end
end
