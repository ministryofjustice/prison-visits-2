class AddNomisCancelledToCancellations < ActiveRecord::Migration[4.2]
  def change
    add_column :cancellations, :nomis_cancelled, :boolean, default: false, null: false
  end
end
