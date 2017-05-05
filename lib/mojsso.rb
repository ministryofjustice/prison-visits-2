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

      # Without this login with sso breaks.
      #
      # Fix as suggested here: https://github.com/intridea/omniauth-oauth2/commit/26152673224aca5c3e918bcc83075dbb0659717f#commitcomment-19809835
      # Other link about the issue: https://github.com/intridea/omniauth-oauth2/issues/81
      #
      # omniauth-oauth2 after version 1.3.1 it changed the way that the callback
      # url gets generated. This new version doesn't match the redirect uri as set in
      # SSO so login breaks (I think it doesn't strip the previous query string,
      # although I would need to double check to be sure)
      #
      # The issue seems quite common among multiple SSO providers like Google,
      # Facebook, Dropbox, etc
      #
      # Detailed information can be found on the comments of the above links.
      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
