# frozen_string_literal: true

class CreateUnbookableDates < ActiveRecord::Migration[5.2]
  def change
    create_table :unbookable_dates, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.uuid :prison_id, null: false
      t.date :date, null: false

      t.timestamps null: false
    end
  end
end
