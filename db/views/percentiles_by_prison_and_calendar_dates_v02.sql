SELECT prisons.name                                                    AS prison_name,
       prisons.id                                                      AS prison_id,
       (v.created_at::TIMESTAMPTZ AT TIME ZONE 'Europe/London')::date  AS date,
       PERCENTILE_DISC(ARRAY[0.95, 0.5]) WITHIN GROUP (ORDER BY ROUND(EXTRACT(EPOCH FROM vsc.created_at - v.created_at))::integer) AS percentiles
FROM visits AS v
INNER JOIN (SELECT MAX(created_at) AS created_at, visit_id, visit_state FROM visit_state_changes GROUP BY visit_id, visit_state) AS vsc ON v.id = vsc.visit_id
INNER JOIN prisons ON prisons.id = v.prison_id
WHERE vsc.visit_state IN ('booked', 'rejected')
GROUP BY prison_name,
         prisons.id,
         date;
