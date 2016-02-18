class CreateCountVisitsByPrisonAndStates < ActiveRecord::Migration
  def change
    execute 'DROP VIEW IF EXISTS count_visits_by_prison_and_states;'
    create_view :count_visits_by_prison_and_states
  end
end
