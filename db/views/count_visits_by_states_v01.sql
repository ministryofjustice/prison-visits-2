SELECT
  processing_state,
  COUNT(*)::integer
FROM visits
GROUP BY processing_state
