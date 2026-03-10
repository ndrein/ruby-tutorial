class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :users, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :email, limit: 255, null: false
      t.string :experience_level, limit: 20, null: false, default: "expert"
      t.string :password_digest, limit: 255, null: false
      t.integer :streak_count, null: false, default: 0
      t.date :last_session_date
      t.boolean :email_opted_in, null: false, default: false
      t.integer :email_delivery_hour, null: false, default: 8
      t.string :timezone, limit: 100, null: false, default: "UTC"

      t.timestamps null: false, default: -> { "NOW()" }
    end

    add_index :users, :email, unique: true

    execute <<~SQL
      ALTER TABLE users
        ADD CONSTRAINT chk_users_experience_level
          CHECK (experience_level IN ('expert', 'beginner')),
        ADD CONSTRAINT chk_users_streak_count
          CHECK (streak_count >= 0),
        ADD CONSTRAINT chk_users_email_delivery_hour
          CHECK (email_delivery_hour BETWEEN 0 AND 23);
    SQL
  end
end
