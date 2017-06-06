class AddTypeColumnToVisitors < ActiveRecord::Migration
  def change
    add_column :visitors, :type, :string
    Visitor.where(sort_index: 0).update_all(type: 'LeadVisitor')
    change_column :visitors, :type, :string, default: 'Visitor', null: false
  end
end
