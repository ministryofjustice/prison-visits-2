class AddVisitorsNomisId < ActiveRecord::Migration[4.2]
  def change
    add_column :visitors, :nomis_id, :integer
  end
end
