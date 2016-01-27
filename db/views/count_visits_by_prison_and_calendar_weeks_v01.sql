SELECT
  prisons.name AS prison_name,
  extract(isoyear from visits.created_at)::integer AS year,
  extract(week from visits.created_at)::integer AS week,
  processing_state,
  COUNT(*)
FROM visits
INNER JOIN prisons
ON prisons.id = visits.prison_id
GROUP BY
  processing_state,
  prison_name,
  week,
  year
