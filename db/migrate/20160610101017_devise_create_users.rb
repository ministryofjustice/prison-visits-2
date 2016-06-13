class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table :users, id: :uuid do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Rememberable
      t.datetime :remember_created_at

      t.uuid :estate_id, null: false

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :estate_id, unique: true
    add_foreign_key :users, :estates
  end
end
