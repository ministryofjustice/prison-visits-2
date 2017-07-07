class CreateRejectionPercentageByDays < ActiveRecord::Migration[4.2]
  def change
    create_view :rejection_percentage_by_days, materialized: true
  end
end
