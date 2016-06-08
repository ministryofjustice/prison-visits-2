class AddCancellations < ActiveRecord::Migration
  def change
    create_table :cancellations, id: :uuid do |t|
      t.uuid :visit_id, null: false
      t.string :reason, null: false
      t.timestamps
    end

    add_foreign_key :cancellations, :visits
    add_index :cancellations, :visit_id, unique: true
  end
end
