class CreateTimelyAndOverdueByCalendarWeeks < ActiveRecord::Migration
  def change
    create_view :timely_and_overdue_by_calendar_weeks
  end
end
