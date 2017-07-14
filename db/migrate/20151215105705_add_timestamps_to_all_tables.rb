class AddTimestampsToAllTables < ActiveRecord::Migration[4.2]
  TABLES = %i[ feedback_submissions prisoners rejections ]
  COLUMNS = %i[ created_at updated_at ]

  def up
    TABLES.each do |table|
      COLUMNS.each do |column|
        add_column table, column, :datetime
        execute <<-SQL
          UPDATE #{table}
          SET #{column} = now();
        SQL
        change_column_null table, column, false
      end
    end
  end

  def down
    TABLES.each do |table|
      COLUMNS.each do |column|
        remove_column table, column
      end
    end
  end
end
