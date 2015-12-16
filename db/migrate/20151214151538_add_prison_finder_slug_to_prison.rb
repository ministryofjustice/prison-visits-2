class AddPrisonFinderSlugToPrison < ActiveRecord::Migration
  def up
    add_column :prisons, :finder_slug, :string
    execute <<-SQL
      UPDATE prisons
      SET finder_slug = regexp_replace(lower(name), '[^a-z]+', '-', 'g');
    SQL
    change_column_null :prisons, :finder_slug, false
  end

  def down
    remove_column :prisons, :finder_slug
  end
end
