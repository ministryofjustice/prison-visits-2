sendgrid_api = SendgridApi.new(api_user: ENV['SMTP_USERNAME'],
                               api_key: ENV['SMTP_PASSWORD'],
                               timeout: 2) # seconds

sendgrid_api.configure_pool(pool_size: ActiveRecord::Base.connection.pool.size,
                            pool_timeout: 1) # seconds

Rails.configuration.sendgrid_api = sendgrid_api
