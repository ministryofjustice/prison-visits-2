class AddBannedAndNotOnListToVisitors < ActiveRecord::Migration[4.2]
  def change
    add_column :visitors, :banned, :boolean
    add_column :visitors, :not_on_list, :boolean
  end
end
