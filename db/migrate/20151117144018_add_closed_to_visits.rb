class AddClosedToVisits < ActiveRecord::Migration[4.2]
  def change
    add_column :visits, :closed, :boolean
  end
end
