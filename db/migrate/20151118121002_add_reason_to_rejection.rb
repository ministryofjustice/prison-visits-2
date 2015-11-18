class AddReasonToRejection < ActiveRecord::Migration
  def change
    add_column :rejections, :reason, :string, null: false
  end
end
