class AddViewsForCalculatingPercentiles < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE VIEW distributions AS
        SELECT percentile_disc(ARRAY[0.99, 0.95, 0.90, 0.75, 0.50, 0.25])
                 WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM vsc.created_at - v.created_at)) AS percentiles
        FROM visits AS v
        INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected');

      CREATE VIEW distribution_by_prisons AS
        SELECT prisons.name AS prison_name,
               PERCENTILE_DISC(ARRAY[0.99, 0.95, 0.90, 0.75, 0.50, 0.25])
                 WITHIN GROUP (ORDER BY ROUND(EXTRACT(EPOCH FROM vsc.created_at - v.created_at))::integer) AS percentiles
        FROM visits AS v
        INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected')
        INNER JOIN prisons ON prisons.id = v.prison_id
        GROUP BY prison_name;

      CREATE VIEW distribution_by_prison_and_calendar_weeks AS
        SELECT prisons.name AS prison_name,
               PERCENTILE_DISC(ARRAY[0.99, 0.95, 0.90, 0.75, 0.50, 0.25])
                 WITHIN GROUP (ORDER BY ROUND(EXTRACT(EPOCH FROM vsc.created_at - v.created_at))::integer) AS percentiles,
               extract(isoyear from v.created_at)::integer AS year,
               extract(week from v.created_at)::integer AS week
        FROM visits AS v
        INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected')
        INNER JOIN prisons ON prisons.id = v.prison_id
        GROUP BY prison_name,
                 week,
                 year;

      CREATE VIEW distribution_by_prison_and_calendar_dates AS
        SELECT prisons.name AS prison_name,
               PERCENTILE_DISC(ARRAY[0.99, 0.95, 0.90, 0.75, 0.50, 0.25])
                 WITHIN GROUP (ORDER BY ROUND(EXTRACT(EPOCH FROM vsc.created_at - v.created_at))::integer) AS percentiles,
               extract(year from v.created_at)::integer AS year,
               extract(month from v.created_at)::integer AS month,
               extract(day from v.created_at)::integer AS day
        FROM visits AS v
        INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected')
        INNER JOIN prisons ON prisons.id = v.prison_id
        GROUP BY prison_name,
                 day,
                 month,
                 year;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW distributions;
      DROP VIEW distributions_for_individual_prisons;
      DROP VIEW distributions_for_prisons_by_calendar_weeks;
      DROP VIEW distributions_for_prisons_by_calendar_dates;
    SQL
  end
end
