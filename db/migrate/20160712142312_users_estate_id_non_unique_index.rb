class UsersEstateIdNonUniqueIndex < ActiveRecord::Migration[4.2]
  def change
    remove_index :users, :estate_id
    add_index :users, :estate_id
  end
end
