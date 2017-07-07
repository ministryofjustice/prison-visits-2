class AddReferenceNoToVisit < ActiveRecord::Migration[4.2]
  def change
    add_column :visits, :reference_no, :string
  end
end
