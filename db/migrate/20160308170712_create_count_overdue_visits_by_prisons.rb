class CreateCountOverdueVisitsByPrisons < ActiveRecord::Migration[4.2]
  def change
    execute 'DROP VIEW IF EXISTS count_overdue_visits_by_prisons;'
    create_view :count_overdue_visits_by_prisons
  end
end
