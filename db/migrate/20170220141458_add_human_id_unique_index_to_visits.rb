class AddHumanIdUniqueIndexToVisits < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def change
    add_index :visits, :human_id, unique: true, algorithm: :concurrently
  end
end
