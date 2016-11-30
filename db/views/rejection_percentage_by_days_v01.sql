WITH rejection_reasons AS (
  SELECT visit_id, unnest(reasons) AS reason
  FROM rejections
  GROUP BY visit_id, reasons
),

rejected_visits_count_by_prison AS (
  SELECT prisons.name            AS prison_name,
         prisons.id              AS prison_id,
         visits.created_at::date AS date,
         COUNT(*)                AS rejected_count
  FROM visits
  INNER JOIN prisons ON prisons.id = visits.prison_id
  WHERE visits.processing_state    = 'rejected'
  GROUP BY prison_name, prisons.id, date
),

visit_count_by_prison AS (
  SELECT prisons.name            AS prison_name,
         prisons.id              AS prison_id,
         COUNT(*)                AS total_count,
         visits.created_at::date AS date
  FROM visits
  INNER JOIN prisons ON prisons.id = visits.prison_id
  GROUP BY prison_name, prisons.id, date
),
rejected_visit_count_reason_date_and_prison AS (
  SELECT reason,
         prisons.name            AS prison_name,
         prisons.id              AS prison_id,
         COUNT(*)                AS rejected_count,
         visits.created_at::date AS date
  FROM visits
  INNER JOIN prisons           ON prisons.id = visits.prison_id
  INNER JOIN rejection_reasons ON visits.id  = rejection_reasons.visit_id
  WHERE visits.processing_state = 'rejected'
  GROUP BY prison_name, prisons.id, reason, date
),
visit_count_by_prison_and_date AS (
  SELECT prisons.name            AS prison_name,
         prisons.id              AS prison_id,
         COUNT(*)                AS total_count,
         visits.created_at::date AS date
  FROM visits
  INNER JOIN prisons ON prisons.id = visits.prison_id
  GROUP BY prison_name, prisons.id, date
)

SELECT rejected.prison_name,
       rejected.prison_id                                     AS prison_id,
       'total'                                                AS reason,
       ROUND((rejected_count::numeric / total_count * 100),2) AS percentage,
       rejected.date                                          AS date
FROM
  rejected_visits_count_by_prison AS rejected,
  visit_count_by_prison           AS total
WHERE rejected.prison_id = total.prison_id AND rejected.date = total.date
GROUP BY rejected.prison_name, rejected.prison_id, reason, percentage, rejected.date

UNION

SELECT rejected.prison_name,
       rejected.prison_id,
       reason,
       ROUND((rejected_count::numeric / total_count * 100),2) AS percentage,
       rejected.date                                          AS date
FROM
  rejected_visit_count_reason_date_and_prison AS rejected,
  visit_count_by_prison_and_date              AS  total
WHERE rejected.prison_name = total.prison_name AND rejected.date = total.date
GROUP BY rejected.prison_name, rejected.prison_id, reason, percentage, rejected.date
