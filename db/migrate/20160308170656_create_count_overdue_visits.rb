class CreateCountOverdueVisits < ActiveRecord::Migration[4.2]
  def change
    execute 'DROP VIEW IF EXISTS count_overdue_visits;'
    create_view :count_overdue_visits
  end
end
