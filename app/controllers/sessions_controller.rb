class SessionsController < ApplicationController
  def create
    user = User.from_sso(omniauth_info)

    if user
      session[:current_user_id] = user.id

      redirect_to session.delete(:redirect_path) || prison_inbox_path
    else
      flash[:notice] = t('.cannot_sign_in')
      redirect_to root_path
    end
  end

  def destroy
    session.delete(:current_user_id)
    redirect_to root_path
  end

private

  # Set by the omni auth strategy in lib/mojsso.rb
  def omniauth_info
    request.env['omniauth.auth'].fetch('info')
  end
end
