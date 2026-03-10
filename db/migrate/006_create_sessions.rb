class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.uuid :user_id, null: false
      t.datetime :started_at, null: false, precision: 6, default: -> { "NOW()" }
      t.datetime :ended_at, precision: 6
      t.integer :duration_seconds
      t.integer :exercises_completed, null: false, default: 0
      t.date :session_date, null: false

      t.datetime :created_at, null: false, precision: 6, default: -> { "NOW()" }
    end

    add_foreign_key :sessions, :users, on_delete: :cascade
    add_index :sessions, [:user_id, :session_date]

    execute <<~SQL
      ALTER TABLE sessions
        ADD CONSTRAINT chk_sessions_duration_seconds
          CHECK (duration_seconds IS NULL OR duration_seconds >= 0),
        ADD CONSTRAINT chk_sessions_exercises_completed
          CHECK (exercises_completed >= 0);
    SQL
  end
end
