class CreateLessons < ActiveRecord::Migration[8.1]
  def change
    create_table :lessons, id: :integer do |t|
      t.integer :module_id, null: false
      t.string :title, limit: 255, null: false
      t.integer :position_in_module, null: false
      t.text :content_body, null: false
      t.text :python_equivalent, null: false
      t.text :java_equivalent, null: false
      t.integer :estimated_minutes, null: false, default: 5
      t.integer :prerequisite_ids, array: true, null: false, default: []

      t.datetime :created_at, null: false, precision: 6, default: -> { "NOW()" }
    end

    add_foreign_key :lessons, :modules
    add_index :lessons, :module_id
    add_index :lessons, [:module_id, :position_in_module], unique: true

    execute <<~SQL
      ALTER TABLE lessons
        ADD CONSTRAINT chk_lessons_position_in_module
          CHECK (position_in_module BETWEEN 1 AND 5),
        ADD CONSTRAINT chk_lessons_estimated_minutes
          CHECK (estimated_minutes BETWEEN 1 AND 5);
    SQL
  end
end
