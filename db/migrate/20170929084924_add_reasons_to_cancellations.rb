class AddReasonsToCancellations < ActiveRecord::Migration[5.1]
  def change
    add_column :cancellations, :reasons, :string, array: true, default: []
  end
end
