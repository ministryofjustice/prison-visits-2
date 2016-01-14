class AddPostcodeToPrison < ActiveRecord::Migration
  def change
    add_column :prisons, :postcode, :string, limit: 8
  end
end
