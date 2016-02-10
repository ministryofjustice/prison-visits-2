class AddViewsForCountingOverdueVisits < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE VIEW count_overdue_visits AS
        SELECT COUNT(*),
               vsc.visit_state AS visit_state
        FROM visits AS v
        INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected')
        WHERE (EXTRACT(EPOCH FROM vsc.created_at - v.created_at) > 259200)
        GROUP BY visit_state
      UNION
        SELECT COUNT(*),
               processing_state AS visit_state
        FROM visits AS v
        WHERE (EXTRACT(EPOCH FROM v.created_at) > 259200)
        AND ((SELECT COUNT(*) FROM visit_state_changes WHERE v.id = visit_id) = 0)
        GROUP BY visit_state;

      CREATE VIEW count_overdue_visits_by_prisons AS
        SELECT COUNT(*),
               vsc.visit_state AS visit_state,
               prisons.name AS prison_name
        FROM visits AS v
        INNER JOIN prisons ON prisons.id = v.prison_id
        INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected')
        WHERE EXTRACT(EPOCH FROM vsc.created_at - v.created_at) > 259200
        GROUP BY prison_name,
                 visit_state
      UNION
        SELECT COUNT(*),
               processing_state AS visit_state,
               prisons.name AS prison_name
        FROM visits AS v
        INNER JOIN prisons ON prisons.id = v.prison_id
        WHERE (EXTRACT(EPOCH FROM v.created_at) > 259200)
        AND ((SELECT COUNT(*) FROM visit_state_changes WHERE v.id = visit_id) = 0)
        GROUP BY prison_name,
                 processing_state;

      CREATE VIEW count_overdue_visits_by_prison_and_calendar_weeks AS
        SELECT COUNT(*),
               vsc.visit_state AS visit_state,
               prisons.name AS prison_name,
               extract(week from v.created_at)::integer AS week,
               extract(isoyear from v.created_at)::integer AS year
          FROM visits AS v
        INNER JOIN prisons ON prisons.id = v.prison_id
        INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected')
        WHERE EXTRACT(EPOCH FROM vsc.created_at - v.created_at) > 259200
        GROUP BY visit_state,
                 prison_name,
                 week,
                 year
      UNION
        SELECT COUNT(*),
               processing_state AS visit_state,
               prisons.name AS prison_name,
               extract(week from v.created_at)::integer AS week,
               extract(isoyear from v.created_at)::integer AS year
        FROM visits AS v
        INNER JOIN prisons ON prisons.id = v.prison_id
        WHERE (EXTRACT(EPOCH FROM v.created_at) > 259200)
        AND ((SELECT COUNT(*) FROM visit_state_changes WHERE v.id = visit_id) = 0)
        GROUP BY visit_state,
                 prison_name,
                 week,
                 year;

      CREATE VIEW count_overdue_visits_by_prison_and_calendar_dates AS
        SELECT COUNT(*),
               vsc.visit_state AS visit_state,
               prisons.name AS prison_name,
               extract(day from v.created_at)::integer AS day,
               extract(month from v.created_at)::integer AS month,
               extract(year from v.created_at)::integer AS year
          FROM visits AS v
        INNER JOIN prisons ON prisons.id = v.prison_id
        INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected')
        WHERE EXTRACT(EPOCH FROM vsc.created_at - v.created_at) > 259200
        GROUP BY visit_state,
                 prison_name,
                 day,
                 month,
                 year
      UNION
        SELECT COUNT(*),
               processing_state AS visit_state,
               prisons.name AS prison_name,
               extract(day from v.created_at)::integer AS day,
               extract(month from v.created_at)::integer AS month,
               extract(year from v.created_at)::integer AS year
        FROM visits AS v
        INNER JOIN prisons ON prisons.id = v.prison_id
        WHERE (EXTRACT(EPOCH FROM v.created_at) > 259200)
        AND ((SELECT COUNT(*) FROM visit_state_changes WHERE v.id = visit_id) = 0)
        GROUP BY visit_state,
                 prison_name,
                 day,
                 month,
                 year;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW count_overdue_visits;
      DROP VIEW count_overdue_visits_by_prisons;
      DROP VIEW count_overdue_visits_by_prison_and_calendar_weeks;
      DROP VIEW count_overdue_visits_by_prison_and_calendar_dates;
    SQL
  end
end
