class UpdateDistributionsToVersion2 < ActiveRecord::Migration[4.2]
  def change
    update_view :distributions, version: 2, revert_to_version: 1
    update_view :distribution_by_prisons, version: 2, revert_to_version: 1
    update_view :distribution_by_prison_and_calendar_weeks, version: 2, revert_to_version: 1
    update_view :distribution_by_prison_and_calendar_dates, version: 2, revert_to_version: 1
  end
end
