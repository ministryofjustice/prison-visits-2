require 'excon'

module Nomis
  APIError = Class.new(StandardError)

  class Client
    TIMEOUT = 1 # seconds

    def initialize(host)
      @host = host
      @connection = Excon.new(
        host,
        persistent: true,
        connect_timeout: TIMEOUT,
        read_timeout: TIMEOUT,
        write_timeout: TIMEOUT
      )
    end

    def get(route, params = {})
      request(:get, route, params)
    end

  # def post(route, params)
  #   request(:post, route, params)
  # end

  private

    # rubocop:disable Metrics/MethodLength
    def request(method, route, params)
      # For cleanliness, strip initial / if supplied
      route = route.sub(%r{^\/}, '')
      path = "/nomisapi/#{route}"

      options = {
        method: method,
        path: path,
        expects: [200],
        headers: {
          'Accept' => 'application/json',
          'X-Request-Id' => RequestStore.store[:request_id]
        }
      }.deep_merge(params_options(method, params))

      Rails.logger.info do
        "Calling NOMIS API: #{method.to_s.upcase} #{path}"
      end

      response = @connection.request(options)

      JSON.parse(response.body)
    rescue Excon::Errors::HTTPStatusError => e
      body = e.response.body

      # API errors should be returned as JSON, but there are many scenarios
      # where this may not be the case.
      begin
        error = JSON.parse(body)
      rescue JSON::ParserError
        # Present non-JSON bodies truncated (e.g. this could be HTML)
        error = "(invalid-JSON) #{body[0, 80]}"
      end

      raise APIError,
        "Unexpected status #{e.response.status} calling #{api_method}: #{error}"
    rescue Excon::Errors::Error => e
      raise APIError, "Exception #{e.class} calling #{api_method}: #{e}"
    end
    # rubocop:enable Metrics/MethodLength

    # Returns excon options which put params in either the query string or body.
    def params_options(method, params)
      return {} if params.empty?

      if method == :get || method == :delete
        { query: params }
        # else
        #   {
        #     body: params.to_json,
        #     headers: { 'Content-Type' => 'application/json' }
        #   }
      end
    end
  end
end
