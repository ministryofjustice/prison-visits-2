class UpdateTimelyAndOverdueByCalendarWeeksToVersion3 < ActiveRecord::Migration
  def change
    update_view :timely_and_overdue_by_calendar_weeks, version: 3, revert_to_version: 2
  end
end
