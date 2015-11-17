class AddClosedToVisits < ActiveRecord::Migration
  def change
    add_column :visits, :closed, :boolean
  end
end
