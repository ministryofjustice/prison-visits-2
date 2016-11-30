class CreateRejectionPercentageByDays < ActiveRecord::Migration
  def change
    create_view :rejection_percentage_by_days, materialized: true
  end
end
