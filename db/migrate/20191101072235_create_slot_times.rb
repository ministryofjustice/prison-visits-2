# frozen_string_literal:true

class CreateSlotTimes < ActiveRecord::Migration[5.2]
  def change
    create_table :slot_times, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.uuid :slot_day_id
      t.integer :begin_hour
      t.integer :begin_minute
      t.integer :end_hour
      t.integer :end_minute

      t.timestamps
    end
  end
end
