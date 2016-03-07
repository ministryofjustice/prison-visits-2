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

    options = base_opts(timeout).merge(
      path: "api/#{endpoint}",
      query: query.merge(credentials)
    )

    JSON.parse(@connection.get(options).body)
  end

  def post_request(endpoint, data, timeout: TIMEOUT)
    fail Error, 'no credentials set' if credentials_missing?

    options = base_opts(timeout).merge(
      path: "api/#{endpoint}",
      query: data.merge(credentials)
    )

    JSON.parse(@connection.post(options).body)
  end

  def base_opts(timeout)
    {
      expects: [200],
      headers: {
        'Accept' => 'application/json'
      },
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
