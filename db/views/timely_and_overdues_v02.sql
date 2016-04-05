SELECT COUNT(*),
        'overdue' AS status,
         vsc.visit_state AS visit_state,
         prisons.name AS prison_name
  FROM visits AS v
  INNER JOIN prisons ON prisons.id = v.prison_id
  INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected', 'cancelled', 'withdrawn')
  WHERE EXTRACT(EPOCH FROM vsc.created_at - v.created_at) > 259200
    AND vsc.visit_state = v.processing_state
  GROUP BY prison_name,
           visit_state
UNION
SELECT COUNT(*),
        'timely' AS status,
         vsc.visit_state AS visit_state,
         prisons.name AS prison_name
  FROM visits AS v
  INNER JOIN prisons ON prisons.id = v.prison_id
  INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected', 'cancelled', 'withdrawn')
  WHERE EXTRACT(EPOCH FROM vsc.created_at - v.created_at) < 259200
    AND vsc.visit_state = v.processing_state
  GROUP BY prison_name,
           visit_state
