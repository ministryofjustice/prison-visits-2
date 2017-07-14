class MoveNomisIdToEstate < ActiveRecord::Migration[4.2]
  def up
    add_column :estates, :nomis_id, :string, limit: 3
    add_column :estates, :finder_slug, :string

    execute  <<-SQL
      UPDATE estates
      SET nomis_id = prisons.nomis_id, finder_slug = prisons.finder_slug
      FROM prisons
      WHERE estates.id = prisons.estate_id
    SQL

    change_column_null :estates, :nomis_id, false
    change_column_null :estates, :finder_slug, false

    remove_column :prisons, :nomis_id
    remove_column :prisons, :finder_slug
  end

  def down
    add_column :prisons, :nomis_id, :string, limit: 3
    add_column :prisons, :finder_slug, :string

    execute  <<-SQL
      UPDATE prisons
      SET nomis_id = estates.nomis_id, finder_slug = estates.finder_slug
      FROM estates
      WHERE estate_id = estates.id
    SQL

    change_column_null :prisons, :nomis_id, false
    change_column_null :prisons, :finder_slug, false

    remove_column :estates, :nomis_id
    remove_column :estates, :finder_slug
  end
end
