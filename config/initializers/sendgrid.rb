client_opts = { timeout: 2, # seconds
                persistent: true }

pool_opts = { timeout: 1, # seconds
              size: ActiveRecord::Base.connection.pool.size }

sendgrid_api = SendgridApi.new(api_user: ENV['SMTP_USERNAME'],
                               api_key: ENV['SMTP_PASSWORD'],
                               client_opts: client_opts,
                               pool_opts: pool_opts)

# If the app is started with Sendgrid disabled then the API wrapper will behave
# if any API call is successful.
# Sendgrid could be disabled if they are have planned maintenance for example.
sendgrid_api.disable unless Rails.configuration.enable_sendgrid_validations

Rails.configuration.sendgrid_api = sendgrid_api
