class CreateRejectionPercentageByPrisonAndCalendarWeeks < ActiveRecord::Migration
  def change
    create_view :rejection_percentage_by_prison_and_calendar_weeks
  end
end
