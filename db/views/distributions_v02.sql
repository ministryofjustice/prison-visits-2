SELECT percentile_disc(ARRAY[0.95,0.50])
         WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM vsc.created_at - v.created_at)) AS percentiles
FROM visits AS v
INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected');
