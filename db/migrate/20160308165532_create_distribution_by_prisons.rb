class CreateDistributionByPrisons < ActiveRecord::Migration[4.2]
  def change
    execute 'DROP VIEW IF EXISTS distribution_by_prisons;'
    create_view :distribution_by_prisons
  end
end
