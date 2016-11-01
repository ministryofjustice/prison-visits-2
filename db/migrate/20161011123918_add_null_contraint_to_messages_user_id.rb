class AddNullContraintToMessagesUserId < ActiveRecord::Migration
  def change
    change_column_null :messages, :user_id, false
  end
end
