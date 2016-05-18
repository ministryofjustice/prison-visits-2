configurator = lambda do |mailer_klass, env_name, non_prod_default|
  url_value = Rails.env.production? ? ENV.fetch(env_name) : non_prod_default

  service_url = URI.parse(url_value)

  mailer_klass.default_url_options = {
    protocol: service_url.scheme,
    host: service_url.hostname,
    port: service_url.port
  }
end

configurator.call(PrisonMailer, 'STAFF_SERVICE_URL', 'http://localhost:3000')
configurator.call(VisitorMailer, 'PUBLIC_SERVICE_URL', 'http://localhost:4000')
