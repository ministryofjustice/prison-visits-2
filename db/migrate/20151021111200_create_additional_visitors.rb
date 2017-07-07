class CreateAdditionalVisitors < ActiveRecord::Migration[4.2]
  def change
    create_table :additional_visitors do |t|
      t.references :visit, index: true, foreign_key: true, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :date_of_birth, null: false

      t.timestamps null: false
    end
  end
end
