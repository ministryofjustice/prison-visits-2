# frozen_string_literal: true

module Nomis
  module Oauth
    class JwksService
      include Singleton

      HOST = Rails.configuration.nomis_oauth_host

      attr_reader :oauth_client

      def initialize(oauth_client: Nomis::Oauth::Client)
        @oauth_client = oauth_client.new(HOST)
      end

      def fetch_keys
        route = '/auth/.well-known/jwks.json'
        oauth_client.get(route)
      end
    end
  end
end
