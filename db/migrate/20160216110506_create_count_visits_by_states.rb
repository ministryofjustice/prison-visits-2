class CreateCountVisitsByStates < ActiveRecord::Migration
  def change
    create_view :count_visits_by_states
  end
end
