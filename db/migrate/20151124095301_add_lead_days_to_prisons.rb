class AddLeadDaysToPrisons < ActiveRecord::Migration
  def up
    add_column :prisons, :lead_days, :integer
    execute 'UPDATE prisons SET lead_days = 3'
    change_column_null :prisons, :lead_days, false
    change_column_default :prisons, :lead_days, 3

    add_column :prisons, :weekend_processing, :boolean
    execute 'UPDATE prisons SET weekend_processing = false'
    change_column_null :prisons, :weekend_processing, false
    change_column_default :prisons, :weekend_processing, false
  end

  def down
    remove_column :prisons, :weekend_processing
    remove_column :prisons, :lead_days
  end
end
