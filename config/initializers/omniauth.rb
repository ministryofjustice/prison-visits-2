require 'mojsso'

# Used for Heroku review apps.
# SSO app must have a unique id, so when a new heroku review app gets deployed
# we use the name of the heroku app to be the id of a duplicate pvb app.
heroku_app_name = ENV.fetch('HEROKU_APP_NAME', nil)
review_app_id = if heroku_app_name
                  # Same value as used in the heroku rake task
                  "Prison Visits Booking (review app: #{heroku_app_name})"
                end

# Heroku review apps don't inherit the MOJSSO_ID environment variable.
sso_app_id = ENV.fetch('MOJSSO_ID', review_app_id)
Rails.configuration.sso_app_id = sso_app_id

sso_app_secret = ENV.fetch('MOJSSO_SECRET', nil)

sso_url = ENV.fetch('MOJSSO_URL', 'http://localhost:5000')
Rails.configuration.sso_url = sso_url

unless sso_app_id && sso_app_secret && sso_url
  STDOUT.puts '[WARN] MOJSSO_ID/MOJSSO_SECRET/MOJSSO_URL not configured'
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :mojsso,
    Rails.configuration.sso_app_id,
    sso_app_secret,
    client_options: { site: Rails.configuration.sso_url })
end
