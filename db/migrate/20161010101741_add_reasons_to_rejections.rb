class AddReasonsToRejections < ActiveRecord::Migration[4.2]
  def change
    add_column :rejections, :reasons, :string, array: true, default: []
  end
end
