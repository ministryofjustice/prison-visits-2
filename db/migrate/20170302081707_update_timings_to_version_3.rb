class UpdateTimingsToVersion3 < ActiveRecord::Migration[4.2]
  def change
    update_view :timely_and_overdues, version: 3, revert_to_version: 2
  end
end
