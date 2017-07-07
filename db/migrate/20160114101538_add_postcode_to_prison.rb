class AddPostcodeToPrison < ActiveRecord::Migration[4.2]
  def change
    add_column :prisons, :postcode, :string, limit: 8
  end
end
