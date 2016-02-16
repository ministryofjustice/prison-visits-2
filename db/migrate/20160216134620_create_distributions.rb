class CreateDistributions < ActiveRecord::Migration
  def change
    create_view :distributions
  end
end
