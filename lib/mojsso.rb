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

      # HACK: tl;dr
      # Don't happen query fragment to the callback_url (i.e bypass CSRF protection)
      # as the Sign On Doorkeeper gem is broken.
      # See this PR https://github.com/doorkeeper-gem/doorkeeper/pull/974
      #
      # During the Oauth flow when a user is already logged in MoJ sign on
      # but not in PVB staff (or any other client for that matter) when attempting
      # to get an oauth token omniauth appends a
      # "?state=1223109j1109hr&code=2093f209f208hc023hr" to the url provided in
      # the callback_url param.
      # Doorkeeper (moj-signon) matches the callback_url provided with the POST request
      # against the callback_url provided when created the oauth application.
      # This fails if the callback_url params has any query string appended to it.
      # See: https://github.com/doorkeeper-gem/doorkeeper/pull/974/files#diff-5c1f9daf0b81d01ceeeb79eaea1cbbe2L47
      #
      # Once PR https://github.com/doorkeeper-gem/doorkeeper/pull/974
      # is merged we can update the Sign On app and get rid of this
      # which essentially bypass the CSRF check in omniauth.
      # And we'd love CSRF check to happen, wouldn't we?
      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
