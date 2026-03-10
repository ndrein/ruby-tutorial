# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 7) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "daily_queues", force: :cascade do |t|
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "email_sent_at"
    t.integer "exercise_ids", default: [], null: false, array: true
    t.date "queue_date", null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "queue_date"], name: "index_daily_queues_on_user_id_and_queue_date", unique: true
    t.index ["user_id"], name: "idx_daily_queues_unsent", where: "(email_sent_at IS NULL)"
  end

  create_table "exercises", id: :serial, force: :cascade do |t|
    t.text "accepted_synonyms", default: [], null: false, array: true
    t.string "correct_answer", limit: 500, null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.string "exercise_type", limit: 30, null: false
    t.text "explanation", null: false
    t.integer "lesson_id", null: false
    t.text "options", default: [], null: false, array: true
    t.integer "position", default: 1, null: false
    t.text "prompt", null: false
    t.index ["lesson_id", "position"], name: "index_exercises_on_lesson_id_and_position", unique: true
    t.index ["lesson_id"], name: "index_exercises_on_lesson_id"
    t.check_constraint "exercise_type::text = ANY (ARRAY['fill_in_blank'::character varying::text, 'multiple_choice'::character varying::text, 'spot_the_bug'::character varying::text, 'translation'::character varying::text])", name: "chk_exercises_exercise_type"
  end

  create_table "lessons", id: :serial, force: :cascade do |t|
    t.text "content_body", null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.integer "estimated_minutes", default: 5, null: false
    t.text "java_equivalent", null: false
    t.integer "module_id", null: false
    t.integer "position_in_module", null: false
    t.integer "prerequisite_ids", default: [], null: false, array: true
    t.text "python_equivalent", null: false
    t.string "title", limit: 255, null: false
    t.index ["module_id", "position_in_module"], name: "index_lessons_on_module_id_and_position_in_module", unique: true
    t.index ["module_id"], name: "index_lessons_on_module_id"
    t.check_constraint "estimated_minutes >= 1 AND estimated_minutes <= 5", name: "chk_lessons_estimated_minutes"
    t.check_constraint "position_in_module >= 1 AND position_in_module <= 5", name: "chk_lessons_position_in_module"
  end

  create_table "modules", id: :serial, force: :cascade do |t|
    t.integer "position", null: false
    t.string "title", limit: 255, null: false
    t.index ["position"], name: "index_modules_on_position", unique: true
    t.check_constraint "\"position\" >= 1 AND \"position\" <= 5", name: "chk_modules_position"
  end

  create_table "reviews", force: :cascade do |t|
    t.string "answer_result", limit: 20, null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.integer "exercise_id", null: false
    t.date "next_review_date", null: false
    t.integer "quality_score", default: 0, null: false
    t.integer "repetitions", default: 0, null: false
    t.datetime "reviewed_at"
    t.decimal "sm2_ease_factor", precision: 4, scale: 2, default: "2.5", null: false
    t.integer "sm2_interval", default: 1, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "exercise_id"], name: "index_reviews_on_user_id_and_exercise_id", unique: true
    t.index ["user_id", "next_review_date"], name: "index_reviews_on_user_id_and_next_review_date"
    t.check_constraint "answer_result::text = ANY (ARRAY['correct'::character varying::text, 'incorrect'::character varying::text, 'skipped'::character varying::text, 'timeout'::character varying::text])", name: "chk_reviews_answer_result"
    t.check_constraint "quality_score >= 0 AND quality_score <= 5", name: "chk_reviews_quality_score"
    t.check_constraint "repetitions >= 0", name: "chk_reviews_repetitions"
    t.check_constraint "sm2_ease_factor >= 1.30 AND sm2_ease_factor <= 2.50", name: "chk_reviews_sm2_ease_factor"
    t.check_constraint "sm2_interval >= 1", name: "chk_reviews_sm2_interval"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.integer "duration_seconds"
    t.datetime "ended_at"
    t.integer "exercises_completed", default: 0, null: false
    t.date "session_date", null: false
    t.datetime "started_at", default: -> { "now()" }, null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "session_date"], name: "index_sessions_on_user_id_and_session_date"
    t.check_constraint "duration_seconds IS NULL OR duration_seconds >= 0", name: "chk_sessions_duration_seconds"
    t.check_constraint "exercises_completed >= 0", name: "chk_sessions_exercises_completed"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.string "email", limit: 255, null: false
    t.integer "email_delivery_hour", default: 8, null: false
    t.boolean "email_opted_in", default: false, null: false
    t.string "experience_level", limit: 20, default: "expert", null: false
    t.date "last_session_date"
    t.string "password_digest", limit: 255, null: false
    t.integer "streak_count", default: 0, null: false
    t.string "timezone", limit: 100, default: "UTC", null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.check_constraint "email_delivery_hour >= 0 AND email_delivery_hour <= 23", name: "chk_users_email_delivery_hour"
    t.check_constraint "experience_level::text = ANY (ARRAY['expert'::character varying::text, 'beginner'::character varying::text])", name: "chk_users_experience_level"
    t.check_constraint "streak_count >= 0", name: "chk_users_streak_count"
  end

  add_foreign_key "daily_queues", "users", on_delete: :cascade
  add_foreign_key "exercises", "lessons"
  add_foreign_key "lessons", "modules"
  add_foreign_key "reviews", "exercises"
  add_foreign_key "reviews", "users", on_delete: :cascade
  add_foreign_key "sessions", "users", on_delete: :cascade
end
