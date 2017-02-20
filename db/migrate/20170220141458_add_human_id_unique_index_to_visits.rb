class AddHumanIdUniqueIndexToVisits < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :visits, :human_id, unique: true, algorithm: :concurrently
  end
end
