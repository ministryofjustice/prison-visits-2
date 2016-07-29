class SessionsController < ApplicationController
  def create
    identity = SignonIdentity.from_omniauth(request.env['omniauth.auth'])

    if identity
      session[:sso_data] = identity.to_session
      redirect_to session.delete(:redirect_path) || prison_inbox_path
    else
      flash[:notice] = t('.cannot_sign_in')
      redirect_to root_path
    end
  end

  def destroy
    if sso_identity
      sso_logout_url = sso_identity.logout_url(redirect_to: root_url)
      session.delete(:sso_data)
      redirect_to sso_logout_url
    else
      redirect_to root_url
    end
  end
end
