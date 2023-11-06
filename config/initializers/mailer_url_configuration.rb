# rubocop:disable Style/MultilineTernaryOperator
env_name = 'PUBLIC_SERVICE_URL'
url_value = Rails.env.production? ?
              ENV.fetch(env_name) :
              ENV.fetch(env_name, 'http://localhost:4000')
# rubocop:enable Style/MultilineTernaryOperator

service_url = URI.parse(url_value)

Rails.application.config.to_prepare do
  VisitorMailer.default_url_options = {
    protocol: service_url.scheme,
    host: service_url.hostname,
    port: service_url.port
  }
end
