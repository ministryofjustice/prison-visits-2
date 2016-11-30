class CreatePercentilesByPrisonAndCalendarDates < ActiveRecord::Migration
  def change
    create_view :percentiles_by_prison_and_calendar_dates, materialized: true
  end
end
