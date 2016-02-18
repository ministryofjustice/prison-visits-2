class CreateCountVisitsByPrisonAndCalendarWeeks < ActiveRecord::Migration
  def change
    execute 'DROP VIEW IF EXISTS count_visits_by_prison_and_calendar_weeks;'
    create_view :count_visits_by_prison_and_calendar_weeks
  end
end
