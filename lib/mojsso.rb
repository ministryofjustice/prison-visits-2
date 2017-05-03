require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Mojsso < OmniAuth::Strategies::OAuth2
      option :name, 'mojsso'
      option :client_options, site: ''

      uid do
        raw_info.fetch('id')
      end

      info do
        {
          first_name: raw_info.fetch('first_name'),
          last_name: raw_info.fetch('last_name'),
          email: raw_info.fetch('email'),
          permissions: raw_info.fetch('permissions'),
          links: raw_info.fetch('links')
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        @raw_info ||= access_token.get('/api/user_details').parsed
      end

      # As suggested here: https://github.com/intridea/omniauth-oauth2/commit/26152673224aca5c3e918bcc83075dbb0659717f#commitcomment-19809835
      # Other link about the issue: https://github.com/intridea/omniauth-oauth2/issues/81
      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
