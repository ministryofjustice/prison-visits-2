class AddTypeColumnToVisitors < ActiveRecord::Migration
  def change
    add_column :visitors, :type, :string
  end
end
