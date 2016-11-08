class AddVisitorIdToVisitStateChanges < ActiveRecord::Migration
  def up
    add_reference :visit_state_changes, :visitor, type: :uuid, foreign_key: true
    execute <<-EOS
ALTER TABLE visit_state_changes \
  ADD CONSTRAINT visitor_or_processed_by_set \
  CHECK (visitor_id IS NULL OR processed_by_id IS NULL)
    EOS
  end

  def down
    execute <<-EOS
ALTER TABLE visit_state_changes \
  DROP CONSTRAINT visitor_or_processed_by_set
EOS
    remove_reference :visit_state_changes, :visitor
  end
end
