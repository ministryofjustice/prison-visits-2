class CreateCountOverdueVisitsByPrisonAndCalendarWeeks < ActiveRecord::Migration[4.2]
  def change
    execute 'DROP VIEW IF EXISTS count_overdue_visits_by_prison_and_calendar_weeks;'
    create_view :count_overdue_visits_by_prison_and_calendar_weeks
  end
end
