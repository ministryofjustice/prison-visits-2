class AddClosedFlagToPrisons < ActiveRecord::Migration[4.2]
  def change
    add_column :prisons, :closed,  :boolean, default: :false, null: false
    add_column :prisons, :private, :boolean, default: :false, null: false
  end
end
