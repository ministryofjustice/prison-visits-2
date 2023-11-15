# frozen_string_literal: true

module Nomis
  module Oauth
    class TokenService
      include Singleton

      class_attribute :host

      self.host = Rails.configuration.nomis_oauth_host

      class << self
        delegate :valid_token, to: :instance
      end

      def valid_token
        set_new_token if token.expired? || token.access_token.nil?
        token
      end

    private

      def set_new_token
        @token = fetch_token
      end

      def token
        @token ||= fetch_token
      end

      def fetch_token
        oauth_client = Nomis::Oauth::Client.new(host)
        route = '/auth/oauth/token?grant_type=client_credentials'
        response = oauth_client.post(route)
        Token.from_json(response)
      end
    end
  end
end
