class CreateRejectionPercentages < ActiveRecord::Migration
  def change
    create_view :rejection_percentages
  end
end
