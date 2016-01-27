class CreateCountVisitsByPrisonAndStates < ActiveRecord::Migration
  def change
    create_view :count_visits_by_prison_and_states
  end
end
