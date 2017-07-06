class RemoveReasonFromRejections < ActiveRecord::Migration[5.1]
  def change
    remove_column :rejections, :reason
  end
end
