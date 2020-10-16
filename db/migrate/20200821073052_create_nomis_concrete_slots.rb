class CreateNomisConcreteSlots < ActiveRecord::Migration[5.2]
  def change
    create_table :nomis_concrete_slots, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.references :prison, type: :uuid, null: false
      t.date :date, null: false
      t.integer :start_hour, null: false
      t.integer :start_minute, null: false
      t.integer :end_hour, null: false
      t.integer :end_minute, null: false

      t.timestamps
    end
  end
end
