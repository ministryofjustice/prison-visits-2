class CreateVisitCountsByPrisonStateDateAndTimely < ActiveRecord::Migration[4.2]
  def change
    create_view :visit_counts_by_prison_state_date_and_timely, materialized: true
  end
end
