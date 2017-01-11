class AddBannedUntilOnVisitors < ActiveRecord::Migration
  def change
    add_column :visitors, :banned_until, :date
  end
end
