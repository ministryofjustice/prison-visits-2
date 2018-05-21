class AddAdminsToEstates < ActiveRecord::Migration[5.2]
  def change
    add_column :estates, :admins, :string, array: true, default: []
  end
end
