# frozen_string_literal: true

module Nomis
  module Oauth
    class Client
      def initialize(host)
        @host = host
        @connection = Faraday.new
      end

      def post(route)
        response = @connection.send(:post) { |req|
          url = URI.join(@host, route).to_s
          req.url(url)
          req.headers['Authorization'] = authorisation
        }

        JSON.parse(response.body)
      end

    private
      def authorisation
        'Basic ' + Base64.urlsafe_encode64(
          "#{Rails.configuration.nomis_oauth_client_id}:#{Rails.configuration.nomis_oauth_client_secret}"
        )
      end
      
    end
  end
end
