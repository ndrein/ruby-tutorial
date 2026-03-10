class CreateModules < ActiveRecord::Migration[8.1]
  def change
    create_table :modules, id: :integer do |t|
      t.string :title, limit: 255, null: false
      t.integer :position, null: false
    end

    add_index :modules, :position, unique: true

    execute <<~SQL
      ALTER TABLE modules
        ADD CONSTRAINT chk_modules_position
          CHECK (position BETWEEN 1 AND 5);
    SQL
  end
end
