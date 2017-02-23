class AddHumanIdToVisits < ActiveRecord::Migration
  def change
    add_column :visits, :human_id, :string
  end
end
