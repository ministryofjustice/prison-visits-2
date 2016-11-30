class CreatePercentilesByCalendarDates < ActiveRecord::Migration
  def change
    create_view :percentiles_by_calendar_dates, materialized: true
  end
end
