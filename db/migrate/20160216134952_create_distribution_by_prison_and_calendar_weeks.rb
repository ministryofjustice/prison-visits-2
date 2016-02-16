class CreateDistributionByPrisonAndCalendarWeeks < ActiveRecord::Migration
  def change
    create_view :distribution_by_prison_and_calendar_weeks
  end
end
