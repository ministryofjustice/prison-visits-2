class CreateVisitStateChanges < ActiveRecord::Migration
  def change
    create_table :visit_state_changes, id: :uuid do |t|
      t.string :visit_state
      t.uuid :visit_id, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
