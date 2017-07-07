class AddPrisonerModel < ActiveRecord::Migration[4.2]
  def up
    create_table :prisoners, id: :uuid do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :date_of_birth, null: false
      t.string :number, null: false
    end

    add_column :visits, :prisoner_id, :uuid

    execute <<-SQL
      UPDATE visits SET prisoner_id = uuid_generate_v4();
    SQL

    change_column_null :visits, :prisoner_id, false

    execute <<-SQL
      INSERT INTO prisoners
        (id, first_name, last_name, date_of_birth, number)
      SELECT prisoner_id, prisoner_first_name, prisoner_last_name,
        prisoner_date_of_birth, prisoner_number
      FROM visits
    SQL

    remove_column :visits, :prisoner_first_name
    remove_column :visits, :prisoner_last_name
    remove_column :visits, :prisoner_date_of_birth
    remove_column :visits, :prisoner_number

    add_foreign_key :visits, :prisoners
  end
end
