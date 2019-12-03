# frozen_string_literal: true

require 'base64'

module Nomis
  module Oauth
    class Token
      attr_writer :expires_in,
                  :internal_user,
                  :token_type,
                  :auth_source,
                  :jti

      attr_accessor :access_token,
                    :scope

      def initialize(fields = {})
        # Allow this object to be reconstituted from a hash, we can't use
        # from_json as the one passed in will already be using the snake case
        # names whereas from_json is expecting the elite2 camelcase names.
        fields.each { |k, v| instance_variable_set("@#{k}", v) } if fields.present?
      end

      def expired?
        x = payload.fetch('exp')
        expiry_seconds = Time.zone.at(x) - Time.zone.now
        # consider token expired if it has less than 10 seconds to go
        expiry_seconds < 10
      rescue JWT::ExpiredSignature => e
        Raven.capture_exception(e)
        true
      end

      def payload
        @payload ||= JWT.decode(
          access_token,
          OpenSSL::PKey::RSA.new(public_key),
          true,
          algorithm: 'RS256'
        ).first
      end

      def self.from_json(payload)
        Token.new.tap { |obj|
          obj.access_token = payload['access_token']
          obj.token_type = payload['token_type']
          obj.expires_in = payload.fetch('expires_in')
          obj.scope = payload['scope']
          obj.internal_user = payload['internal_user']
          obj.jti = payload['jti']
          obj.auth_source = payload['auth_source']
        }
      end

    private

      def public_key
        @public_key ||= Base64.urlsafe_decode64(
          Rails.configuration.nomis_oauth_public_key
        )
      end
    end
  end
end
