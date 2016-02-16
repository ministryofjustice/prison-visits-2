SELECT prisons.name AS prison_name,
       processing_state,
       COUNT(*)
FROM visits
INNER JOIN prisons ON prisons.id = visits.prison_id
GROUP BY processing_state,
         prison_name;
