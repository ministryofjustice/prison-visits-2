class SendgridClient
  TIMEOUT = 2 # seconds

  attr_reader :api_key, :api_user

  def initialize(api_key:, api_user:, http_opts: {})
    timeout = http_opts.fetch(:timeout, TIMEOUT)
    persistent = http_opts.fetch(:persistent, false)

    @api_key = api_key
    @api_user = api_user

    @connection = Excon.new('https://api.sendgrid.com',
                            persistent: persistent,
                            connect_timeout: timeout)
  end

  def request(verb, endpoint, query, timeout: TIMEOUT)
    request_opts = options(verb, endpoint, query, timeout)
    response = @connection.request(request_opts).body
    JSON.parse(response)
  end

  def options(verb, endpoint, query, timeout)
    {
      expects: [200],
      headers: { 'Accept' => 'application/json' },
      method: verb,
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
end
