class AddLocaleToVisit < ActiveRecord::Migration
  def up
    add_column :visits, :locale, :string, limit: 2
    execute <<-SQL
      UPDATE visits SET locale = 'en'
    SQL
    change_column_null :visits, :locale, false
  end

  def down
    remove_column :visits, :locale
  end
end
