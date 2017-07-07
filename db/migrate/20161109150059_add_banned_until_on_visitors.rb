class AddBannedUntilOnVisitors < ActiveRecord::Migration[4.2]
  def change
    add_column :visitors, :banned_until, :date
  end
end
