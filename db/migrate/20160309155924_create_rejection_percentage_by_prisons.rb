class CreateRejectionPercentageByPrisons < ActiveRecord::Migration[4.2]
  def change
    create_view :rejection_percentage_by_prisons
  end
end
