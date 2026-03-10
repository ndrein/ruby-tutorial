class CreateExercises < ActiveRecord::Migration[8.1]
  def change
    create_table :exercises, id: :integer do |t|
      t.integer :lesson_id, null: false
      t.string :exercise_type, limit: 30, null: false
      t.text :prompt, null: false
      t.string :correct_answer, limit: 500, null: false
      t.text :accepted_synonyms, array: true, null: false, default: []
      t.text :explanation, null: false
      t.text :options, array: true, null: false, default: []
      t.integer :position, null: false, default: 1

      t.datetime :created_at, null: false, precision: 6, default: -> { "NOW()" }
    end

    add_foreign_key :exercises, :lessons
    add_index :exercises, :lesson_id
    add_index :exercises, [:lesson_id, :position], unique: true

    execute <<~SQL
      ALTER TABLE exercises
        ADD CONSTRAINT chk_exercises_exercise_type
          CHECK (exercise_type IN ('fill_in_blank', 'multiple_choice', 'spot_the_bug', 'translation'));
    SQL
  end
end
