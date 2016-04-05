class UpdateTimelyAndOverduesToVersion3 < ActiveRecord::Migration
  def change
    update_view :timely_and_overdues, version: 3, revert_to_version: 2
  end
end
