WITH visits_timely AS (
     SELECT
          prisons.name AS prison_name,
          prisons.id   AS prison_id,
          v.processing_state,
          v.created_at,
          (
            CASE
            WHEN processing_state IN ('booked', 'rejected')
              THEN (vsc.created_at - v.created_at)::interval < '3 days'::interval
            ELSE
              NULL
            END
          )::boolean AS timely
    FROM visits v
    LEFT OUTER JOIN (SELECT MAX(created_at) AS created_at, visit_id FROM visit_state_changes GROUP BY visit_id) vsc ON vsc.visit_id = v.id
    LEFT OUTER JOIN prisons ON prisons.id = v.prison_id
)

SELECT
    v.prison_name,
    v.prison_id,
    v.processing_state,
    v.timely,
    v.created_at::date AS date,
    COUNT(*)
FROM visits_timely v
GROUP BY
      v.prison_name,
      v.prison_id,
      v.processing_state,
      v.timely,
      date;
