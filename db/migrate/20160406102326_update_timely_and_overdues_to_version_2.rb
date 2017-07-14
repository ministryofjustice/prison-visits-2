class UpdateTimelyAndOverduesToVersion2 < ActiveRecord::Migration[4.2]
  def change
    update_view :timely_and_overdues, version: 2, revert_to_version: 1
  end
end
