class UpdateRejectionPercentageByPrisonAndCalendarWeeksToVersion4 < ActiveRecord::Migration
  def change
    update_view :rejection_percentage_by_prison_and_calendar_weeks, version: 4, revert_to_version: 3
  end
end
