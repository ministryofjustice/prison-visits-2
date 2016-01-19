class AddViewsForCalculatingPercentiles < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE VIEW processing_times_by_prison_and_state AS
        SELECT prisons.name AS prison_name,
               vsc.visit_state AS state,
               percentile_cont(0.95)
                 WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM vsc.created_at - v.created_at)::integer)::integer AS ninety_fifth,
               percentile_cont(0.50)
                 WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM vsc.created_at - v.created_at)::integer)::integer AS median
          FROM visits AS v
          INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected')
          INNER JOIN prisons ON prisons.id = v.prison_id
          GROUP BY prison_name,
                   state
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW processing_times_by_prison_and_state;
    SQL
  end
end
