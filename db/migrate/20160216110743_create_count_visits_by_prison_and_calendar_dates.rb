class CreateCountVisitsByPrisonAndCalendarDates < ActiveRecord::Migration
  def change
    create_view :count_visits_by_prison_and_calendar_dates
  end
end
