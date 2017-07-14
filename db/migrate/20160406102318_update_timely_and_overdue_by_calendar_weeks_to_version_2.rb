class UpdateTimelyAndOverdueByCalendarWeeksToVersion2 < ActiveRecord::Migration[4.2]
  def change
    update_view :timely_and_overdue_by_calendar_weeks, version: 2, revert_to_version: 1
  end
end
