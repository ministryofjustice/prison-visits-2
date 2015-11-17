class ZeroIndexSlots < ActiveRecord::Migration
  def up
    rename_column :visits, :slot_option_1, :slot_option_0
    rename_column :visits, :slot_option_2, :slot_option_1
    rename_column :visits, :slot_option_3, :slot_option_2
  end

  def down
    rename_column :visits, :slot_option_2, :slot_option_3
    rename_column :visits, :slot_option_1, :slot_option_2
    rename_column :visits, :slot_option_0, :slot_option_1
  end
end
