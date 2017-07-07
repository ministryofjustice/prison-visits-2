class AddReasonToRejection < ActiveRecord::Migration[4.2]
  def change
    add_column :rejections, :reason, :string, null: false
  end
end
