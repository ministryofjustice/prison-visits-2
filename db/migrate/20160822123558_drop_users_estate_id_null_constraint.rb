class DropUsersEstateIdNullConstraint < ActiveRecord::Migration
  def change
    change_column_null :users, :estate_id, true
  end
end
