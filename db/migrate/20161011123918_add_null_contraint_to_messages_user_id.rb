class AddNullContraintToMessagesUserId < ActiveRecord::Migration[4.2]
  def change
    change_column_null :messages, :user_id, false
  end
end
