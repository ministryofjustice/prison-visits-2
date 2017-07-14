class CreateCountVisitsByPrisonAndCalendarDates < ActiveRecord::Migration[4.2]
  def change
    execute 'DROP VIEW IF EXISTS count_visits_by_prison_and_calendar_dates;'
    create_view :count_visits_by_prison_and_calendar_dates
  end
end
