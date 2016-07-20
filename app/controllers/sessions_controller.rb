class SessionsController < ApplicationController
  def create
    user = User.from_sso(omniauth_info)
    session[:sso_data] = omniauth_info

    if user
      session[:current_user_id] = user.id

      redirect_to session.delete(:redirect_path) || prison_inbox_path
    else
      flash[:notice] = t('.cannot_sign_in')
      redirect_to root_path
    end
  end

  def destroy
    sso_signout_url = sso_link(:logout)
    session.delete(:current_user_id)
    session.delete(:sso_data)
    redirect_to sso_signout_url
  end

private

  # Set by the omni auth strategy in lib/mojsso.rb
  def omniauth_info
    request.env['omniauth.auth'].fetch('info')
  end
end
