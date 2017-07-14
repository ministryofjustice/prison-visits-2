class DropUsersEstateIdNullConstraint < ActiveRecord::Migration[4.2]
  def change
    change_column_null :users, :estate_id, true
  end
end
