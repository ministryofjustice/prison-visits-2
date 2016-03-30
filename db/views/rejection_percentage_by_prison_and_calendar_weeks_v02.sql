SELECT rejected.prison_name,
       'total' AS reason,
       rejected.year AS year,
       rejected.week AS week,
       ROUND((rejected_count::numeric / booked_count * 100),2) AS percentage
FROM (SELECT prisons.name AS prison_name,
             count(*) AS rejected_count,
             extract(isoyear from visits.created_at)::integer AS year,
             extract(week from visits.created_at)::integer AS week
      FROM visits
      INNER JOIN prisons ON prisons.id = visits.prison_id
      WHERE visits.processing_state = 'rejected'
      GROUP BY prison_name,
             prison_id,
               year,
               week
      ) rejected,
     (SELECT prisons.name AS prison_name,
             count(*) AS booked_count
      FROM visits
      INNER JOIN prisons ON prisons.id = visits.prison_id
      GROUP BY prison_name,
               prison_id
      ) booked
WHERE rejected.prison_name = booked.prison_name
GROUP BY rejected.prison_name,
         reason,
         percentage,
         year,
         week
UNION
SELECT rejected.prison_name,
       reason,
       rejected.year AS year,
       rejected.week AS week,
       ROUND((rejected_count::numeric / booked_count * 100),2) AS percentage
FROM (SELECT reason,
             prisons.name AS prison_name,
             count(*) AS rejected_count,
             extract(isoyear from visits.created_at)::integer AS year,
             extract(week from visits.created_at)::integer AS week
      FROM visits
      INNER JOIN prisons ON prisons.id = visits.prison_id
      INNER JOIN rejections ON rejections.visit_id = visits.id
      WHERE visits.processing_state = 'rejected'
      GROUP BY prison_name,
             prison_id,
               reason,
               year,
               week
      ) rejected,
     (SELECT prisons.name AS prison_name,
             count(*) AS booked_count
      FROM visits
      INNER JOIN prisons ON prisons.id = visits.prison_id
      GROUP BY prison_name,
               prison_id
      ) booked
WHERE rejected.prison_name = booked.prison_name
GROUP BY rejected.prison_name,
         reason,
         percentage,
         year,
         week
