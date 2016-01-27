class CreateCountVisitsByPrisonAndCalendarWeeks < ActiveRecord::Migration
  def change
    create_view :count_visits_by_prison_and_calendar_weeks
  end
end
