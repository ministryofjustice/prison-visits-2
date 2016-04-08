class UpdateRejectionPercentageByPrisonsToVersion2 < ActiveRecord::Migration
  def change
    update_view :rejection_percentage_by_prisons, version: 2, revert_to_version: 1
  end
end
