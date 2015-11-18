class RestoreForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key "additional_visitors", "visits"
    add_foreign_key "visits", "prisons"
  end
end
