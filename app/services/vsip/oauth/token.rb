# frozen_string_literal: true

require 'base64'

module Vsip
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

      def self.from_json(payload)
        Token.new(payload)
      end
    end
  end
end
