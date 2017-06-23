class AddNomisOffenderIdToPrisoners < ActiveRecord::Migration
  def change
    add_column :prisoners, :nomis_offender_id, :integer
  end
end
