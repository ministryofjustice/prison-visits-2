class UpdateRejectionPercentagesToVersion3 < ActiveRecord::Migration[4.2]
  def change
    update_view :rejection_percentages, version: 3, revert_to_version: 2
  end
end
