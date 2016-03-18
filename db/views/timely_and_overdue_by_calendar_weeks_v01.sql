SELECT COUNT(*),
        'overdue' AS status,
         vsc.visit_state AS visit_state,
         prisons.name AS prison_name,
         extract(week from v.created_at)::integer AS week,
         extract(isoyear from v.created_at)::integer AS year
  FROM visits AS v
  INNER JOIN prisons ON prisons.id = v.prison_id
  INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected')
  WHERE EXTRACT(EPOCH FROM vsc.created_at - v.created_at) > 259200
  GROUP BY prison_name,
           visit_state,
           week,
           year
UNION
SELECT COUNT(*),
        'timely' AS status,
         vsc.visit_state AS visit_state,
         prisons.name AS prison_name,
         extract(week from v.created_at)::integer AS week,
         extract(isoyear from v.created_at)::integer AS year
  FROM visits AS v
  INNER JOIN prisons ON prisons.id = v.prison_id
  INNER JOIN visit_state_changes AS vsc ON v.id = vsc.visit_id AND vsc.visit_state IN ('booked', 'rejected')
  WHERE EXTRACT(EPOCH FROM vsc.created_at - v.created_at) < 259200
  GROUP BY prison_name,
           visit_state,
           week,
           year
