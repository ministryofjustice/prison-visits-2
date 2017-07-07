class CreateRejectionPercentages < ActiveRecord::Migration[4.2]
  def change
    create_view :rejection_percentages
  end
end
