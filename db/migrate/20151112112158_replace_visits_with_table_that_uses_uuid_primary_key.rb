class ReplaceVisitsWithTableThatUsesUuidPrimaryKey < ActiveRecord::Migration
  def change
    create_table :visits, id: :uuid do |t|
      t.uuid :prison_id, index: true, foreign_key: true, null: false
      t.string :prisoner_first_name, null: false
      t.string :prisoner_last_name, null: false
      t.date :prisoner_date_of_birth, null: false
      t.string :prisoner_number, null: false
      t.string :visitor_first_name, null: false
      t.string :visitor_last_name, null: false
      t.date :visitor_date_of_birth, null: false
      t.string :visitor_email_address, null: false
      t.string :visitor_phone_no, null: false
      t.string :slot_option_1, null: false
      t.string :slot_option_2
      t.string :slot_option_3
      t.string :slot_granted
      t.string :processing_state, null: false, default: 'requested'

      t.timestamps null: false
    end
  end
end
