class AddNomisCancelledToCancellations < ActiveRecord::Migration
  def change
    add_column :cancellations, :nomis_cancelled, :boolean, default: false, null: false
  end
end
