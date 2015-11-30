class EnforceSortIndexUniqueness < ActiveRecord::Migration
  def change
    add_index :visitors, %i[ visit_id sort_index ], unique: true
  end
end
