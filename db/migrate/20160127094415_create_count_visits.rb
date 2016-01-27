class CreateCountVisits < ActiveRecord::Migration
  def change
    create_view :count_visits
  end
end
