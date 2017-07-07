class CreatePercentilesByCalendarDates < ActiveRecord::Migration[4.2]
  def change
    create_view :percentiles_by_calendar_dates, materialized: true
  end
end
