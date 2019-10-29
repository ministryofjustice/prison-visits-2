require 'excon'
require 'excon/middleware/custom_idempotent'
require 'excon/middleware/custom_instrumentor'
require 'excon/middleware/deadline'

module Nomis
  APIError = Class.new(StandardError)

  # This client is **NOT** thread safe. To be used with a connection pool. See below.
  class Client
    TIMEOUT = 2 # seconds
    EXCON_INSTRUMENT_NAME = 'nomis_api'.freeze
    JSON_MIME_TYPE = 'application/json'.freeze

    # Sets `thread_safe_sockets` to `false` on the Excon connection. Setting
    # to `false` disables Excon connection sockets cache for each thread.
    #
    # This cache means that there is a socket connection for every Excon
    # connection object to the Nomis API for each Thread. This is to make an
    # Excon connection thread safe.
    #
    # For example if Puma runs with 4 threads, and those threads reuse a
    # connection pool of 4 Excon connections which means that effectively there can
    # be up to 16 live connections to the Nomis API.
    #
    # This cache is unnecessary in our case since:
    # - we ensure thread safety by using a connection pool
    # - we end up opening more sockets than necessary (25 vs 5). If we only have
    #   5 puma threads we only need 5 sockets
    # - the cache has a memory leak when there are short lived threads.
    def initialize(host, client_token, client_key)
      @host = host
      @client_token = client_token
      @client_key = client_key

      @connection = Excon.new(
        host, persistent: true,
              connect_timeout: TIMEOUT, read_timeout: TIMEOUT, write_timeout: TIMEOUT,
              middlewares: excon_middlewares, thread_safe_sockets: false,
              instrumentor: ActiveSupport::Notifications,
              instrumentor_name: EXCON_INSTRUMENT_NAME)
    end

    def get(route, params = {})
      request(:get, route, params, idempotent: true)
    end

  private

    # rubocop:disable Metrics/MethodLength
    def request(method, route, params, idempotent:, options: {})
      # For cleanliness, strip initial / if supplied
      route = route.sub(%r{^\/}, '')
      # path = "/v1/#{route}"
      path = "/nomisapi/#{route}"
      api_method = "#{method.to_s.upcase} #{path}"

      options.merge!({
        method: method,
        path: path,
        expects: [200],
        idempotent: idempotent,
        deadline: RequestStore.store[:deadline],
        retry_limit: 2,
        headers: {
          'Accept' => JSON_MIME_TYPE,
          'Authorization' => auth_header,
          'X-Request-Id' => RequestStore.store[:request_id]
        }
      }.deep_merge(params_options(method, params)))

      response = @connection.request(options)

      JSON.parse(response.body)
    rescue Excon::Error::HTTPStatus => e
      body = e.response.body

      # API errors should be returned as JSON, but there are many scenarios
      # where this may not be the case.
      begin
        error = JSON.parse(body)
      rescue JSON::ParserError
        # Present non-JSON bodies truncated (e.g. this could be HTML)
        error = "(invalid-JSON) #{body[0, 80]}"
      end

      PVB::ExceptionHandler.capture_exception(e, fingerprint: excon_fingerprint)
      raise APIError,
            "Unexpected status #{e.response.status} calling #{api_method}: #{error}"
    rescue Excon::Errors::Error => e
      PVB::ExceptionHandler.capture_exception(e, fingerprint: excon_fingerprint)
      raise APIError, "Exception #{e.class} calling #{api_method}: #{e}"
    end
    # rubocop:enable Metrics/MethodLength

    # Returns excon options which put params in either the query string or body.
    def params_options(_method, params)
      return {} if params.empty?

      { query: params }
    end

    def auth_header
      return unless @client_token && @client_key

      token = auth_token(@client_token, @client_key)
      "Bearer #{token}"

      # TODO: Replace the above with this ...
      # token = Nomis::Oauth::TokenService.valid_token
      # "Bearer #{token.access_token}"
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

    # Custom middlewares for:
    # - Setting an overall deadline
    # - Modifying the Idempotent middleware so that it doesn't retry Timeouts
    # - Modify the Instrumentor middleware so that it doesn't error on the
    # response call and put it at the start of the stack so that it measures the
    # time taken to read the response.
    def excon_middlewares
      [
        Excon::Middleware::CustomInstrumentor,
        Excon::Middleware::Mock,
        Excon::Middleware::Deadline,
        Excon::Middleware::ResponseParser,
        Excon::Middleware::Expects,
        Excon::Middleware::CustomIdempotent
      ]
    end
  end
end
