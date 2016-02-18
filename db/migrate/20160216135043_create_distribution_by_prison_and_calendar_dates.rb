class CreateDistributionByPrisonAndCalendarDates < ActiveRecord::Migration
  def change
    execute 'DROP VIEW IF EXISTS distribution_by_prison_and_calendar_dates;'
    create_view :distribution_by_prison_and_calendar_dates
  end
end
