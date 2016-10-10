class AddReasonsToRejections < ActiveRecord::Migration
  def change
    add_column :rejections, :reasons, :string, array: true, default: []
  end
end
