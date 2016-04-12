class ChangeRejectionViewsToEmptyTables < ActiveRecord::Migration
  def change
    drop_view :rejection_percentages
    drop_view :rejection_percentage_by_prisons
    drop_view :rejection_percentage_by_prison_and_calendar_weeks
    drop_view :rejection_percentage_by_prison_and_calendar_dates
    # Dummy tables to replace the views. These allow use of find_by_sql, which
    # means that we don't have to manually cast the results.
    create_table :rejection_percentage_by_prisons
    create_table :rejection_percentage_by_prison_and_calendar_weeks
  end
end
