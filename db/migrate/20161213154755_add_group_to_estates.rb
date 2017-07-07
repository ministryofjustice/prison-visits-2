class AddGroupToEstates < ActiveRecord::Migration[4.2]
  def change
    add_column :estates, :group, :string
  end
end
