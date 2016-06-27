class SessionsController < ApplicationController
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def create
    auth_hash = request.env['omniauth.auth']
    email = auth_hash.fetch('info').fetch('email')

    # For not only allow authorize exisiting users, since we cannot yet
    # determine which estate a new user should be assigned to
    user = User.find_by(email: email)

    if user
      session[:current_user_id] = user.id

      redirect_path = session.delete(:redirect_path) || root_path
      redirect_to redirect_path
    else
      flash[:notice] = 'You cannot be logged in'
      redirect_to root_path
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def destroy
    session.delete(:current_user_id)
    redirect_to root_url
  end
end
