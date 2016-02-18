class CreateCountOverdueVisits < ActiveRecord::Migration
  def change
    execute 'DROP VIEW IF EXISTS count_overdue_visits;'
    create_view :count_overdue_visits
  end
end
