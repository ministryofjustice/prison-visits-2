class CreateDistributions < ActiveRecord::Migration
  def change
    execute 'DROP VIEW IF EXISTS distributions;'
    create_view :distributions
  end
end
