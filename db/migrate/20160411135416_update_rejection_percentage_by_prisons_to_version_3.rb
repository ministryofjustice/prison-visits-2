class UpdateRejectionPercentageByPrisonsToVersion3 < ActiveRecord::Migration[4.2]
  def change
    update_view :rejection_percentage_by_prisons, version: 3, revert_to_version: 2
  end
end
