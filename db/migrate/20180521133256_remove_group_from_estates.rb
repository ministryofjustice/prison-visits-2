class RemoveGroupFromEstates < ActiveRecord::Migration[5.2]
  def change
    remove_column :estates, :group, :string
  end
end
