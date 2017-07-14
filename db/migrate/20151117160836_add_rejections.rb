class AddRejections < ActiveRecord::Migration[4.2]
  def change
    create_table :rejections, id: :uuid do |t|
      t.uuid :visit_id, null: false
      t.date :vo_renewed_on
      t.date :pvo_expires_on
    end

    add_foreign_key :rejections, :visits
    add_index :rejections, :visit_id, unique: true
  end
end
