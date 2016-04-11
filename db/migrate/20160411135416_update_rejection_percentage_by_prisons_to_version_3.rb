class UpdateRejectionPercentageByPrisonsToVersion3 < ActiveRecord::Migration
  def change
    update_view :rejection_percentage_by_prisons, version: 3, revert_to_version: 2
  end
end
