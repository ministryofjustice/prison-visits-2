class AddNomisOffenderIdToPrisoners < ActiveRecord::Migration[4.2]
  def change
    add_column :prisoners, :nomis_offender_id, :integer
  end
end
