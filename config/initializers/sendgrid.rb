sendgrid_api = SendgridApi.new(api_user: ENV['SMTP_USERNAME'],
                               api_key: ENV['SMTP_PASSWORD'],
                               timeout: 2) # seconds

if Rails.configuration.enable_sendgrid_validations
  sendgrid_api.configure_pool(
    pool_size: ActiveRecord::Base.connection.pool.size,
    pool_timeout: 1) # seconds
end

Rails.configuration.sendgrid_api = sendgrid_api
