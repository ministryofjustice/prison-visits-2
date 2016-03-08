class SendgridClient
  TIMEOUT = 2 # seconds

  class Error < StandardError; end

  attr_reader :api_key, :api_user

  def initialize(api_key:, api_user:, http_opts: {})
    timeout = http_opts.fetch(:timeout, TIMEOUT)
    persistent = http_opts.fetch(:persistent, false)

    @connection ||= Excon.new('https://api.sendgrid.com',
      persistent: persistent,
      connect_timeout: timeout)

    @api_key = api_key
    @api_user = api_user
  end

  def get_request(endpoint, query, timeout: TIMEOUT)
    fail Error, 'no credentials set' if credentials_missing?

    JSON.parse(@connection.get(options(endpoint, query, timeout)).body)
  end

  def post_request(endpoint, data, timeout: TIMEOUT)
    fail Error, 'no credentials set' if credentials_missing?

    JSON.parse(@connection.post(options(endpoint, data, timeout)).body)
  end

  def options(endpoint, query, timeout)
    {
      expects: [200],
      headers: {
        'Accept' => 'application/json'
      },
      path: "api/#{endpoint}",
      # Sendgrid only allows query string for both Post and Get
      query: query.merge(credentials),
      read_timeout: timeout,
      write_timeout: timeout
    }
  end

private

  def credentials
    { api_user: api_user, api_key: api_key }
  end

  def credentials_missing?
    api_user.blank? || api_key.blank?
  end
end
