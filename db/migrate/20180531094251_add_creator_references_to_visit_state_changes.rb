class AddCreatorReferencesToVisitStateChanges < ActiveRecord::Migration[5.2]
  def change
    add_reference :visit_state_changes, :creator, type: :uuid, polymorphic: true, index: true
  end
end
