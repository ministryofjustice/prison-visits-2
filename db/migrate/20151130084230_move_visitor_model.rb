class MoveVisitorModel < ActiveRecord::Migration
  def up
    rename_table :additional_visitors, :visitors
    add_column :visitors, :sort_index, :integer, null: false

    execute <<-SQL
      INSERT INTO visitors
        (visit_id, first_name, last_name, date_of_birth, sort_index)
      SELECT id, visitor_first_name, visitor_last_name,
        visitor_date_of_birth, 0
      FROM visits
    SQL

    remove_column :visits, :visitor_first_name
    remove_column :visits, :visitor_last_name
    remove_column :visits, :visitor_date_of_birth
  end
end
