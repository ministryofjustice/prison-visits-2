require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Mojsso < OmniAuth::Strategies::OAuth2
      option :name, 'mojsso'
      option :client_options,
        site: 'http://localhost:5000',
        authorize_url: 'http://localhost:5000/oauth/authorize'

      uid do
        raw_info['id']
      end

      info do
        {
          email: raw_info['email'],
          permissions: raw_info['permissions']
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
