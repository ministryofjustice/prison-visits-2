class AddViewsForCalculatingPercentiles < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE VIEW calculate_distributions AS
        SELECT percentile_disc(ARRAY[0.99, 0.95, 0.90, 0.75, 0.50, 0.25])
                 WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM vsc.created_at - v.created_at)) AS percentiles
        FROM visits AS v
        INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected');

      CREATE VIEW calculate_distributions_for_prisons AS
        SELECT prisons.name AS prison_name,
               PERCENTILE_DISC(ARRAY[0.99, 0.95, 0.90, 0.75, 0.50, 0.25])
                 WITHIN GROUP (ORDER BY ROUND(EXTRACT(EPOCH FROM vsc.created_at - v.created_at))::integer) AS percentiles
        FROM visits AS v
        INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected')
        INNER JOIN prisons ON prisons.id = v.prison_id
        GROUP BY prison_name;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW calculate_distributions;
      DROP VIEW calculate_distributions_for_individual_prisons;
    SQL
  end
end
