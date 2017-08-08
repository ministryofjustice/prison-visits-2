url_value = if Rails.env.production?
              ENV.fetch('PUBLIC_SERVICE_URL')
            else
              'http://localhost:4000'
            end

service_url = URI.parse(url_value)

VisitorMailer.default_url_options = {
  protocol: service_url.scheme,
  host: service_url.hostname,
  port: service_url.port
}
