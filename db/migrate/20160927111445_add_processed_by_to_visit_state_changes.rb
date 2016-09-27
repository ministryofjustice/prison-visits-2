class AddProcessedByToVisitStateChanges < ActiveRecord::Migration
  def change
    add_column :visit_state_changes, :processed_by_id, :uuid
    add_foreign_key :visit_state_changes, :users, column: :processed_by_id
  end
end
