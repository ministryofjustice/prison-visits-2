SELECT COUNT(*),
         vsc.visit_state AS visit_state
  FROM visits AS v
  INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected')
  WHERE (EXTRACT(EPOCH FROM vsc.created_at - v.created_at) > 259200)
  GROUP BY visit_state
UNION
  SELECT COUNT(*),
         processing_state AS visit_state
  FROM visits AS v
  WHERE (EXTRACT(EPOCH FROM v.created_at) > 259200)
  AND ((SELECT COUNT(*) FROM visit_state_changes WHERE v.id = visit_id) = 0)
  GROUP BY visit_state;
