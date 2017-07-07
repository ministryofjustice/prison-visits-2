class AddAdultAgeToPrison < ActiveRecord::Migration[4.2]
  def up
    add_column :prisons, :adult_age, :integer
    execute 'UPDATE prisons SET adult_age = 18'
    change_column_null :prisons, :adult_age, false
  end

  def down
    remove_column :prisons, :adult_age, :integer
  end
end
