class RemoveProcessedByAndVisitorIdFromVisitStateChanges < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :visit_state_changes, column: :processed_by_id
    remove_foreign_key :visit_state_changes, column: :visitor_id

    change_table :visit_state_changes do |t|
      t.remove :processed_by_id
      t.remove :visitor_id
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
