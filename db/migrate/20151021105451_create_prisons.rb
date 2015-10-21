class CreatePrisons < ActiveRecord::Migration
  def change
    create_table :prisons do |t|
      t.string :name, null: false
      t.string :nomis_id, limit: 3, null: false
      t.boolean :enabled, default: true, null: false
      t.integer :booking_window, default: 28, null: false
      t.text :address
      t.string :email_address
      t.string :phone_no
      t.json :slot_details, default: {}, null: false

      t.timestamps null: false
    end
  end
end
