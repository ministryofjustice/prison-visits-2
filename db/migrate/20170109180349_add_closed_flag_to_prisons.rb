class AddClosedFlagToPrisons < ActiveRecord::Migration
  def change
    add_column :prisons, :closed,  :boolean, default: :false, null: false
    add_column :prisons, :private, :boolean, default: :false, null: false
  end
end
