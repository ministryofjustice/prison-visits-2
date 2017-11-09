class AddRejectionReasonDetailToRejections < ActiveRecord::Migration[5.1]
  def change
    add_column :rejections, :rejection_reason_detail, :string
  end
end
