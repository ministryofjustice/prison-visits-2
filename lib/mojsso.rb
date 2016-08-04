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
    end
  end
end
