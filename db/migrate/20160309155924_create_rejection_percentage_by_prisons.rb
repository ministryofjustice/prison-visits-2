class CreateRejectionPercentageByPrisons < ActiveRecord::Migration
  def change
    create_view :rejection_percentage_by_prisons
  end
end
