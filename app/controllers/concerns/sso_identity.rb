module SSOIdentity
  extend ActiveSupport::Concern

  def sso_identity
    @sso_identity ||=
      begin
        session[:sso_data] && SignonIdentity.from_session_data(session[:sso_data])
      rescue SignonIdentity::InvalidSessionData
        Rails.logger.info \
          "Deleting invalid signon session data: #{session[:sso_data]}"
        session.delete(:sso_data)
        nil
      end
  end
end
