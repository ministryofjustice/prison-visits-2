class AddNomisIdToVisits < ActiveRecord::Migration
  def change
    add_column :visits, :nomis_id, :integer
  end
end
