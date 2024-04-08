class AddVsipToEstate < ActiveRecord::Migration[7.1]
  def change
    add_column :estates, :vsip_supported, :boolean, :default => false
  end
end
