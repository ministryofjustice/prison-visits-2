class CreateDistributionByPrisonAndCalendarWeeks < ActiveRecord::Migration
  def change
    execute 'DROP VIEW IF EXISTS distribution_by_prison_and_calendar_weeks;'
    create_view :distribution_by_prison_and_calendar_weeks
  end
end
