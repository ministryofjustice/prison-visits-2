require 'excon'

module Nomis
  APIError = Class.new(StandardError)

  class Client
    TIMEOUT = 2 # seconds
    EXCON_INSTRUMENT_NAME = 'nomis_api'.freeze

    def initialize(host, client_token, client_key)
      @host = host
      @client_token = client_token
      @client_key = client_key

      @connection = Excon.new(
        host, persistent: true,
              connect_timeout: TIMEOUT, read_timeout: TIMEOUT, write_timeout: TIMEOUT,
              instrumentor: ActiveSupport::Notifications,
              instrumentor_name: EXCON_INSTRUMENT_NAME)
    end

    def get(route, params = {})
      request(:get, route, params, idempotent: true)
    end

  # def post(route, params)
  #   request(:post, route, params)
  # end

  private

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def request(method, route, params, idempotent:)
      # For cleanliness, strip initial / if supplied
      route = route.sub(%r{^\/}, '')
      path = "/nomisapi/#{route}"
      api_method = "#{method.to_s.upcase} #{path}"

      options = {
        method: method,
        path: path,
        expects: [200],
        idempotent: idempotent,
        retry_limit: 2,
        headers: {
          'Accept' => 'application/json',
          'Authorization' => auth_header,
          'X-Request-Id' => RequestStore.store[:request_id]
        }
      }.deep_merge(params_options(method, params))

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

      Raven.capture_exception(e, fingerprint: excon_fingerprint)
      raise APIError,
        "Unexpected status #{e.response.status} calling #{api_method}: #{error}"
    rescue Excon::Errors::Error => e
      Raven.capture_exception(e, fingerprint: excon_fingerprint)
      raise APIError, "Exception #{e.class} calling #{api_method}: #{e}"
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

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

    def auth_header
      return unless @client_token && @client_key

      token = auth_token(@client_token, @client_key)
      "Bearer #{token}"
    end

    def auth_token(client_token, client_key)
      payload = {
        iat: Time.now.to_i,
        token: client_token
      }
      JWT.encode(payload, client_key, 'ES256')
    end

    def excon_fingerprint
      %w[nomis excon]
    end
  end
end
