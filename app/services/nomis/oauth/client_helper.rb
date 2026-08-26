# frozen_string_literal: true

require 'base64'

# simplecov:disable
module Nomis
  module Oauth
    module ClientHelper
      def authorisation
        "Basic #{credentials}"
      end

    private

      def credentials
        Base64.strict_encode64(
          "#{Rails.configuration.nomis_user_oauth_client_id}:#{Rails.configuration.nomis_user_oauth_client_secret}"
        )
      end
    end
  end
end
# simplecov:disable
