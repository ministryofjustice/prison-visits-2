class CreateCountVisits < ActiveRecord::Migration[4.2]
  def change
    execute 'DROP VIEW IF EXISTS count_visits;'
    create_view :count_visits
  end
end
