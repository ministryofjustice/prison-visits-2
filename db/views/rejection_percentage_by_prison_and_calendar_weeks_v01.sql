SELECT rejected.prison_name,
       'total' AS reason,
       extract(isoyear from rejected.created_at)::integer AS year,
       extract(week from rejected.created_at)::integer AS week,
       ROUND((rejected_count::numeric / booked_count * 100),2) AS percentage
FROM (SELECT prisons.name AS prison_name,
             count(*) AS rejected_count,
             rejections.created_at AS created_at
      FROM visits
      INNER JOIN prisons ON prisons.id = visits.prison_id
      INNER JOIN rejections ON rejections.visit_id = visits.id
      WHERE visits.processing_state = 'rejected'
      GROUP BY prison_name,
      		   prison_id,
      		   rejections.created_at
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
         percentage,
         year,
         week
UNION
SELECT rejected.prison_name,
       reason,
       extract(isoyear from rejected.created_at)::integer AS year,
       extract(week from rejected.created_at)::integer AS week,
       ROUND((rejected_count::numeric / booked_count * 100),2) AS percentage
FROM (SELECT reason,
             prisons.name AS prison_name,
             count(*) AS rejected_count,
             rejections.created_at AS created_at
      FROM visits
      INNER JOIN prisons ON prisons.id = visits.prison_id
      INNER JOIN rejections ON rejections.visit_id = visits.id
      WHERE visits.processing_state = 'rejected'
      GROUP BY prison_name,
      		   prison_id,
               reason,
               rejections.created_at
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


