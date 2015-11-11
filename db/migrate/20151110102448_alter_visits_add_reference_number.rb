class AlterVisitsAddReferenceNumber < ActiveRecord::Migration
  def change
    add_column :visits, :reference_number, :string, null: false, index: true
  end
end
