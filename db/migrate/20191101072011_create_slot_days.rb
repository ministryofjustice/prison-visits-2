# frozen_string_literal:true

class CreateSlotDays < ActiveRecord::Migration[5.2]
  def change
    create_table :slot_days, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.uuid :prison_id, null: false
      t.string :day, null: false
      t.date :start_date, null: false

      t.timestamps
    end
  end
end
