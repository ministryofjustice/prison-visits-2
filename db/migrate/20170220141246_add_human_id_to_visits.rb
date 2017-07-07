class AddHumanIdToVisits < ActiveRecord::Migration[4.2]
  def change
    add_column :visits, :human_id, :string
  end
end
