# frozen_string_literal: true

require 'base64'

module Nomis
  module Oauth
    class Token
      attr_accessor :access_token,
                    :token_type,
                    :expires_in,
                    :scope,
                    :internal_user,
                    :jti,
                    :auth_source

      def expired?
        # Try and decode the access_token knowing that it will
        # raise ExpiredSignature if the token itself has
        # expired
        JWT.decode(
          access_token,
          OpenSSL::PKey::RSA.new(public_key),
          true,
          algorithm: 'RS256'
        )
        false
      rescue JWT::ExpiredSignature
        true
      end

      def self.from_json(payload)
        Token.new.tap { |obj|
          obj.access_token = payload['access_token']
          obj.token_type = payload['token_type']
          obj.expires_in = payload['expires_in']
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
