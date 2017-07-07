class CreateDistributions < ActiveRecord::Migration[4.2]
  def change
    execute 'DROP VIEW IF EXISTS distributions;'
    create_view :distributions
  end
end
