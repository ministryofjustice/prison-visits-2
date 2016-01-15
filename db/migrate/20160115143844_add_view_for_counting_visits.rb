class AddViewForCountingVisits < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE VIEW count_visits AS
        SELECT COUNT(*)::integer FROM visits;

      CREATE VIEW count_visits_by_state AS
        SELECT processing_state,
               COUNT(*)::integer
        FROM visits
        GROUP BY processing_state;

      CREATE VIEW count_visits_by_prison_and_state AS
        SELECT prisons.name AS prison_name,
               processing_state,
               COUNT(*)
          FROM visits
        INNER JOIN prisons ON prisons.id = visits.prison_id
        GROUP BY processing_state,
                 prison_name;

      CREATE VIEW count_visits_by_prison_and_calendar_week AS
        SELECT prisons.name AS prison_name,
               extract(isoyear from visits.created_at)::integer AS year,
               extract(week from visits.created_at)::integer AS week,
               processing_state,
               COUNT(*)
          FROM visits
        INNER JOIN prisons ON prisons.id = visits.prison_id
        GROUP BY processing_state,
                 prison_name,
                 week,
                 year;

      CREATE VIEW count_visits_by_prison_and_calendar_dates AS
        SELECT prisons.name AS prison_name,
               extract(year from visits.created_at)::integer AS year,
               extract(month from visits.created_at)::integer AS month,
               extract(day from visits.created_at)::integer AS day,
               processing_state,
               COUNT(*)
          FROM visits
        INNER JOIN prisons ON prisons.id = visits.prison_id
        GROUP BY processing_state,
                 prison_name,
                 day,
                 month,
                 year;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW count_visits;
      DROP VIEW count_visits_by_state;
      DROP VIEW count_visits_by_prison_and_state;
      DROP VIEW count_visits_by_prison_and_calendar_week;
      DROP VIEW count_visits_by_prison_and_calendar_date;
    SQL
  end
end
