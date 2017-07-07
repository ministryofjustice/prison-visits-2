class AlterPrisonsAddEstate < ActiveRecord::Migration[4.2]
  def change
    add_column :prisons, :estate, :string, null: false, index: true
  end
end
