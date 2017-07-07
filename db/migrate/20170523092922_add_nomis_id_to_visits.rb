class AddNomisIdToVisits < ActiveRecord::Migration[4.2]
  def change
    add_column :visits, :nomis_id, :integer
  end
end
