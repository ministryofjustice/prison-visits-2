class UpdateRejectionPercentagesToVersion2 < ActiveRecord::Migration
  def change
    update_view :rejection_percentages, version: 2, revert_to_version: 1
  end
end
