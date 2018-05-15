class RemoveColumnsFromVisits < ActiveRecord::Migration[5.2]
  def change
    remove_column :visits, :override_delivery_error, :boolean
    remove_column :visits, :delivery_error_type, :string
  end
end
