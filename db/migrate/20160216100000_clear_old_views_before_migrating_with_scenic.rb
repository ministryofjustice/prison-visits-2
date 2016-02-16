class ClearOldViewsBeforeMigratingWithScenic < ActiveRecord::Migration
  def change
    execute 'DROP VIEW IF EXISTS count_visits;'
    execute 'DROP VIEW IF EXISTS count_visits_by_state;'
    execute 'DROP VIEW IF EXISTS count_visits_by_prison_and_state;'
    execute 'DROP VIEW IF EXISTS count_visits_by_prison_and_calendar_week;'
    execute 'DROP VIEW IF EXISTS count_visits_by_prison_and_calendar_date;'
    execute 'DROP VIEW IF EXISTS distributions;'
    execute 'DROP VIEW IF EXISTS distributions_for_individual_prisons;'
    execute 'DROP VIEW IF EXISTS distributions_for_prisons_by_calendar_weeks;'
    execute 'DROP VIEW IF EXISTS distributions_for_prisons_by_calendar_dates;'
    execute 'DROP VIEW IF EXISTS count_overdue_visits;'
    execute 'DROP VIEW IF EXISTS count_overdue_visits_by_prisons;'
    execute 'DROP VIEW IF EXISTS count_overdue_visits_by_prison_and_calendear_weeks;'
    execute 'DROP VIEW IF EXISTS count_overdue_visits_by_prison_and_calendear_dates;'
    execute 'DROP VIEW IF EXISTS booked_rejected_splits;'
  end
end
