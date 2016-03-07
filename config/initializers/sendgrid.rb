SendgridPool.instance.configure(
  size: ActiveRecord::Base.connection.pool.size,
  timeout: 1,
  client_attrs: {
    api_key: Rails.configuration.sendgrid_api_key,
    api_user: Rails.configuration.sendgrid_api_user,
    http_opts: {
      persistent: true,
      timeout: 2
    }
  }
)
