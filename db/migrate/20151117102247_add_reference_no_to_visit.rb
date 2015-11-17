class AddReferenceNoToVisit < ActiveRecord::Migration
  def change
    add_column :visits, :reference_no, :string
  end
end
