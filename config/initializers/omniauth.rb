require 'mojsso'

app_id = ENV.fetch('MOJSSO_ID', nil)
app_secret = ENV.fetch('MOJSSO_SECRET', nil)

unless app_id && app_secret
  STDOUT.puts '[WARN] MOJSSO_ID and/or MOJSSO_SECRET not configured'
end

Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :developer unless Rails.env.production?
  provider :mojsso, app_id, app_secret
end
