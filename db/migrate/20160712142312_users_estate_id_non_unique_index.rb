class UsersEstateIdNonUniqueIndex < ActiveRecord::Migration
  def change
    remove_index :users, :estate_id
    add_index :users, :estate_id
  end
end
