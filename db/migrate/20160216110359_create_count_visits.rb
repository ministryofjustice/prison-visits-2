class CreateCountVisits < ActiveRecord::Migration
  def change
    execute 'DROP VIEW IF EXISTS count_visits;'
    create_view :count_visits
  end
end
