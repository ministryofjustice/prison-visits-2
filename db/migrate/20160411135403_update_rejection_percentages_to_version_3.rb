class UpdateRejectionPercentagesToVersion3 < ActiveRecord::Migration
  def change
    update_view :rejection_percentages, version: 3, revert_to_version: 2
  end
end
