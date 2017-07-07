class CreateTimelyAndOverdueByCalendarWeeks < ActiveRecord::Migration[4.2]
  def change
    create_view :timely_and_overdue_by_calendar_weeks
  end
end
