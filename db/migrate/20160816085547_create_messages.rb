class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :body, null: false
      t.references :user
      t.references :visit, null: false
      t.references :visit_state_change
      t.timestamps null: false
    end
  end
end
