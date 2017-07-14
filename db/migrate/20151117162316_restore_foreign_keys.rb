class RestoreForeignKeys < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key "additional_visitors", "visits"
    add_foreign_key "visits", "prisons"
  end
end
