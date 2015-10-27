class AlterPrisonsAddEstate < ActiveRecord::Migration
  def change
    add_column :prisons, :estate, :string, null: false, index: true
  end
end
