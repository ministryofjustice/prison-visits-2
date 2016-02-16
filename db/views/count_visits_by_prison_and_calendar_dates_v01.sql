SELECT prisons.name AS prison_name,
       extract(year from visits.created_at)::integer AS year,
       extract(month from visits.created_at)::integer AS month,
       extract(day from visits.created_at)::integer AS day,
       processing_state,
       COUNT(*)
  FROM visits
INNER JOIN prisons ON prisons.id = visits.prison_id
GROUP BY processing_state,
         prison_name,
         day,
         month,
         year;
