class UpdatePercentilesByPrisonAndCalendarDatesToVersion2 < ActiveRecord::Migration[4.2]
  def change
    update_view :percentiles_by_prison_and_calendar_dates, version: 2, revert_to_version: 1, materialized: true
  end
end
