class CreateCountOverdueVisitsByPrisons < ActiveRecord::Migration
  def change
    create_view :count_overdue_visits_by_prisons
  end
end
