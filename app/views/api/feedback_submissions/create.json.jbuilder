json.feedback_submission do
  json.body @feedback.body
  json.email_address @feedback.email_address
  json.user_agent @feedback.user_agent
  json.referrer @feedback.referrer
end
