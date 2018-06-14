class AddNomisCommentsToVisits < ActiveRecord::Migration[5.2]
  def change
    add_column :visits, :nomis_comments, :string
  end
end
