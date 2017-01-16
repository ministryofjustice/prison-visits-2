SELECT v.created_at::date AS date,
       PERCENTILE_DISC(ARRAY[0.95, 0.5]) WITHIN GROUP (ORDER BY ROUND(EXTRACT(EPOCH FROM (vsc.created_at - v.created_at)))::integer) AS percentiles
FROM visits AS v
INNER JOIN (SELECT MAX(created_at) AS created_at, visit_id FROM visit_state_changes GROUP BY visit_id) AS vsc ON v.id = vsc.visit_id
WHERE v.processing_state IN ('booked', 'rejected')
GROUP BY date;
