# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class HmppsSso < OmniAuth::Strategies::OAuth2
      include Nomis::Oauth::ClientHelper

      option :name, 'hmpps_sso'

      # :nocov:
      info do
        {
          roles: decode_roles,
          organisations: organisations,
          user_id: user_id,
          first_name: user_details.first_name,
          last_name: user_details.last_name
        }
      end

      def build_access_token
        options.token_params[:headers] = { 'Authorization' => authorisation }
        super
      end
      # :nocov:

      # Without this login with sso breaks.
      # This issued was first identified in the Prison Visits Booking service. See
      # https://github.com/ministryofjustice/prison-visits-2/commit/1aaf9fba367b084e1127e3269efbf8e883f3c45b
      # Issue has still not been resolved by the library owners.
      # Fix implemented as suggested here:
      # https://github.com/intridea/omniauth-oauth2/commit/26152673224aca5c3e918bcc83075dbb0659717f#commitcomment-19809835
      # Other link about the issue: https://github.com/intridea/omniauth-oauth2/issues/81
      # omniauth-oauth2 after version 1.3.1 changed the way that the callback
      # url gets generated. This new version doesn't match the redirect uri as set in
      # SSO so login breaks.
      # The issue seems quite common among multiple SSO providers like Google,
      # Facebook, Dropbox, etc

      def callback_url
        full_host + script_name + callback_path
      end

    private

      # :nocov:
      def organisations
        @organisations ||= Nomis::Api.instance.user_caseloads(user_id)
          .select { |c| c.fetch('type') == 'INST' }
          .map { |c| c.fetch('caseLoadId') }
      end

      def decode_roles
        decoded_token = JWT.decode(
          access_token.token,
          nil,
          true,
          algorithm: 'RS256',
          jwks: jwks_keys
        )

        # decoded_token is a pair of hashes. Most of the useful data is in the first hash
        # the second just contains {"alg"=>"RS256", "typ"=>"JWT", "kid"=>"dev-jwk-kid"}
        decoded_token.first.fetch('authorities', [])
      end

      def jwks_keys
        @jwks_keys ||= Nomis::Oauth::JwksService.instance.fetch_keys
      end

      def user_details
        @user_details ||= Nomis::Api.instance.user_details(username)
      end

      def username
        access_token.params.fetch('user_name')
      end

      def user_id
        access_token.params.fetch('user_id')
      end
      # :nocov:
    end
  end
end
