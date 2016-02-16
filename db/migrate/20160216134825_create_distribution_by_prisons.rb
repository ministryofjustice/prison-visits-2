class CreateDistributionByPrisons < ActiveRecord::Migration
  def change
    create_view :distribution_by_prisons
  end
end
