class CreateVisitOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :visit_orders, id: :uuid do |t|
      t.string :type, default: 'VisitOrder', null: false
      t.bigint :number, null: false
      t.string :code, null: false
      t.references :visit, type: :uuid, index: true, foreign_key: true, null: false
      t.timestamps
    end
  end
end
