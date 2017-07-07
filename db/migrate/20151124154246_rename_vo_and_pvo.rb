class RenameVoAndPvo < ActiveRecord::Migration[4.2]
  def change
    rename_column :rejections, :vo_renewed_on, :allowance_renews_on
    rename_column :rejections, :pvo_expires_on, :privileged_allowance_expires_on
  end
end
