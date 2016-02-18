class CreateCountVisitsByStates < ActiveRecord::Migration
  def change
    execute 'DROP VIEW IF EXISTS count_visits_by_states;'
    create_view :count_visits_by_states
  end
end
