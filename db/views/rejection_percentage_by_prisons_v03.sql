SELECT rejected.prison_name,
       'total' AS reason,
       ROUND((rejected_count::numeric / booked_count * 100),2) AS percentage
FROM (SELECT prisons.name AS prison_name,
             count(*) AS rejected_count
      FROM visits
      INNER JOIN prisons ON prisons.id = visits.prison_id
      INNER JOIN rejections ON rejections.visit_id = visits.id
      WHERE visits.processing_state = 'rejected'
      GROUP BY prison_name,
      		   prison_id
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
         percentage
UNION
SELECT rejected.prison_name,
       reason,
       ROUND((rejected_count::numeric / booked_count * 100),2) AS percentage
FROM (SELECT reason,
             prisons.name AS prison_name,
             count(*) AS rejected_count
      FROM visits
      INNER JOIN prisons ON prisons.id = visits.prison_id
      INNER JOIN rejections ON rejections.visit_id = visits.id
      WHERE visits.processing_state = 'rejected'
      GROUP BY prison_name,
      		   prison_id,
               reason
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
         percentage


