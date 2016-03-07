class SendgridClient
  include Singleton

  TIMEOUT = 2 # seconds

  class Error < StandardError; end

  attr_accessor :api_key, :api_user

  def configure(api_key:, api_user:, http_opts: {})
    fail 'Already configured!' if @connection

    timeout = http_opts.fetch(:timeout, TIMEOUT)
    persistent = http_opts.fetch(:persistent, false)

    @connection ||= Excon.new('https://api.sendgrid.com',
      persistent: persistent,
      connect_timeout: timeout)

    @api_key = api_key
    @api_user = api_user
  end

  # rubocop:disable Metrics/MethodLength
  def get_request(endpoint, query, timeout: TIMEOUT)
    fail Error, 'no credentials set' if credentials_missing?

    options = {
      path: "api/#{endpoint}",
      expects: [200],
      headers: {
        'Accept' => 'application/json'
      },
      query: query.merge(credentials),
      read_timeout: timeout,
      write_timeout: timeout
    }

    JSON.parse(@connection.get(options).body)
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def post_request(endpoint, data, timeout: TIMEOUT)
    fail Error, 'no credentials set' if credentials_missing?

    options = {
      path: "/api/#{endpoint}",
      expects: [200],
      headers: {
        'Accept' => 'application/json'
      },
      query: URI.encode_www_form(data.merge(credentials)),
      read_timeout: timeout,
      write_timeout: timeout
    }

    JSON.parse(@connection.post(options).body)
  end
# rubocop:enable Metrics/MethodLength

private

  def credentials
    { api_user: api_user, api_key: api_key }
  end

  def credentials_missing?
    api_user.blank? || api_key.blank?
  end
end
