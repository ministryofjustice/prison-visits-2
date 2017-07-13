class RemoveNonUuidTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :prisons, force: :cascade
    drop_table :additional_visitors, force: :cascade
    drop_table :visits, force: :cascade
  end
end
