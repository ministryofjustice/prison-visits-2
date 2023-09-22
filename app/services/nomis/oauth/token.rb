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
        fields.each do |k, v| instance_variable_set("@#{k}", v) end

        @expiry_time = Time.zone.now + @expires_in.to_i.seconds
      end

      def expired?
        @expiry_time - Time.zone.now < 10
      end

      def valid_token_with_scope?(scope, role: nil)
        return false if payload['scope'].nil?
        return false unless payload['scope'].include? scope

        # For the time being let this through with just a warning log. When we've gathered enough
        # data and informed all the callers, we'll return false here to enforce the correct role
        if role && !payload.fetch('authorities', []).include?(role)
          Rails.logger.warn(
            "event=api_token_missing_role,token_user_name=#{payload['user_name']}," \
            "token_client_id=#{payload['client_id']}}|API access with missing role #{role}"
          )
        end

        true
      rescue JWT::DecodeError, JWT::ExpiredSignature => e
        Sentry.capture_exception(e)
        false
      end
      

      def self.from_json(payload)
        Token.new(payload)
      end
    end
  end
end
