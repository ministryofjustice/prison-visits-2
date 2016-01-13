class AddTranslationsToPrisons < ActiveRecord::Migration
  def up
    add_column :prisons, :translations, :json
    execute <<-SQL
      UPDATE prisons SET translations = '{}'
    SQL
    change_column_null :prisons, :translations, false
    change_column_default :prisons, :translations, {}
  end

  def down
    remove_column :prisons, :translations
  end
end
