require 'mojsso'

app_id = ENV.fetch('MOJSSO_ID', nil)
app_secret = ENV.fetch('MOJSSO_SECRET', nil)
sso_url = ENV.fetch('MOJSSO_URL', 'http://localhost:5000')

unless app_id && app_secret && sso_url
  STDOUT.puts '[WARN] MOJSSO_ID/MOJSSO_SECRET/MOJSSO_URL not configured'
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :mojsso, app_id, app_secret, client_options: { site: sso_url }
end
