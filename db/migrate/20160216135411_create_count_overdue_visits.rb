class CreateCountOverdueVisits < ActiveRecord::Migration
  def change
    create_view :count_overdue_visits
  end
end
