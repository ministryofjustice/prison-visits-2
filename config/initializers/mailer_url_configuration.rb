configurator = lambda do |mailer_klass, env_name|
  local_url_value = 'http://localhost:3000'
  url_value = Rails.env.production? ? ENV.fetch(env_name) : local_url_value

  service_url = URI.parse(url_value)

  mailer_klass.default_url_options = {
    protocol: service_url.scheme,
    host: service_url.hostname,
    port: service_url.port
  }
end

configurator.call(PrisonMailer, 'STAFF_SERVICE_URL')
configurator.call(VisitorMailer, 'PUBLIC_SERVICE_URL')
