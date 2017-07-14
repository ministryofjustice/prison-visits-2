class EnforceSortIndexUniqueness < ActiveRecord::Migration[4.2]
  def change
    add_index :visitors, %i[ visit_id sort_index ], unique: true
  end
end
