class CreateDistributionByPrisonAndCalendarDates < ActiveRecord::Migration
  def change
    create_view :distribution_by_prison_and_calendar_dates
  end
end
