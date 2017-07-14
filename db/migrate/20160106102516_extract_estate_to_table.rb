class ExtractEstateToTable < ActiveRecord::Migration[4.2]
  def up
    create_table :estates, id: :uuid do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :estates, :name, unique: true
    add_column :prisons, :estate_id, :uuid

    execute <<-SQL
      INSERT INTO estates (name)
      SELECT DISTINCT estate FROM prisons
    SQL

    execute <<-SQL
      UPDATE prisons
      SET estate_id = estates.id
      FROM estates
      WHERE estate = estates.name
    SQL

    change_column_null :prisons, :estate_id, false
    remove_column :prisons, :estate
    add_index :prisons, :estate_id
    add_foreign_key :prisons, :estates
  end

  def down
    add_column :prisons, :estate, :string

    execute <<-SQL
      UPDATE prisons
      SET estate = estates.name
      FROM estates
      WHERE estate_id = estates.id
    SQL

    remove_column :prisons, :estate_id
    drop_table :estates
  end
end
