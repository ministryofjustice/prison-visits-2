class CreateMessages < ActiveRecord::Migration[4.2]
  def change
    create_table :messages do |t|
      t.text :body, null: false
      t.references :user, type: :uuid, foreign_key: true
      t.references :visit, type: :uuid, null: false, foreign_key: true
      t.references :visit_state_change, type: :uuid, foreign_key: true
      t.timestamps null: false
    end
  end
end
