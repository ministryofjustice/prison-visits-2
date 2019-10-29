# frozen_string_literal: true

module Nomis
  module Oauth
    class Api
      include Singleton

      class << self
        delegate :fetch_new_auth_token, to: :instance
      end

      def initialize
        host = Rails.configuration.nomis_oauth_host
        @oauth_client = Nomis::Oauth::Client.new(host)
      end

      def fetch_new_auth_token
        route = '/auth/oauth/token?grant_type=client_credentials'
        response = @oauth_client.post(route)
        Token.from_json(response)
      end
    end
  end
end
