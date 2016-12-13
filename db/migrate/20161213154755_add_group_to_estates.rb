class AddGroupToEstates < ActiveRecord::Migration
  def change
    add_column :estates, :group, :string
  end
end
