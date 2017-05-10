class AddVisitorsNomisId < ActiveRecord::Migration
  def change
    add_column :visitors, :nomis_id, :integer
  end
end
