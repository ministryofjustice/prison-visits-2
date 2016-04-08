SELECT 'total' AS reason,
       ROUND((rejected_count::numeric / booked_count * 100),2) AS percentage
FROM (SELECT count(*) AS rejected_count
      FROM visits
      INNER JOIN rejections ON rejections.visit_id = visits.id
      WHERE visits.processing_state = 'rejected'
      ) rejected,
     (SELECT count(*) AS booked_count
      FROM visits
      WHERE visits.processing_state != 'rejected'
      ) booked
GROUP BY percentage
UNION
SELECT reason,
       ROUND((rejected_count::numeric / booked_count * 100),2) AS percentage
FROM (SELECT reason,
             count(*) AS rejected_count
      FROM visits
      INNER JOIN rejections ON rejections.visit_id = visits.id
      WHERE visits.processing_state = 'rejected'
      GROUP BY reason
      ) rejected,
     (SELECT count(*) AS booked_count
      FROM visits
      WHERE visits.processing_state != 'rejected'
     ) booked
GROUP BY reason,
         percentage
