# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :do_not_cache
  before_action :set_locale
  before_action :store_request_id

  before_action :log_current_estates
  before_action :log_current_user

  helper LinksHelper
  helper_method :current_user
  helper_method :sso_identity
  helper_method :current_estates
  helper_method :accessible_estates

  def current_user
    sso_identity&.user
  end

  def current_estates
    return unless sso_identity
    @_current_estates ||= begin
      estate_ids = session[:current_estates]
      estates = estate_ids ? Estate.where(id: estate_ids).to_a : []
      if estates.any? && sso_identity.accessible_estates?(estates)
        estates
      else
        sso_identity.default_estates
      end
    end
  end

  def accessible_estates
    sso_identity.accessible_estates
  end

  def sso_identity
    @_sso_identity ||= begin
      session[:sso_data] && SignonIdentity.from_session_data(session[:sso_data])
    rescue SignonIdentity::InvalidSessionData
      Rails.logger.info \
        "Deleting invalid signon session data: #{session[:sso_data]}"
      session.delete(:sso_data)
      nil
    end
  end

private

  # :nocov:

  def authorize_prison_request
    unless Rails.configuration.prison_ip_matcher.include?(request.remote_ip)
      Rails.logger.info "Unauthorized request from #{request.remote_ip}"
      fail ActionController::RoutingError, 'Not Found'
    end
  end

  def authenticate_user
    unless sso_identity
      session[:redirect_path] = request.original_fullpath
      redirect_to '/auth/mojsso'
    end
  end

  def append_to_log(request_params)
    Instrumentation.append_to_log(request_params)
  end

  # WARNING: This a Rails private method, could easily break in the future.
  #
  # Looks rather strange, but this is the suggested mechanism to add extra data
  # into the event passed to lograge's custom options. The method is part of
  # Rails' instrumentation code, and is run after each request.
  def append_info_to_payload(payload)
    super
    payload[:custom_log_items] = Instrumentation.custom_log_items
  end

  def http_referrer
    request.headers['REFERER']
  end

  def http_user_agent
    request.headers['HTTP_USER_AGENT']
  end

  def do_not_cache
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
  end

  def default_url_options(*)
    { locale: I18n.locale }
  end

  def set_locale
    locale = params[:locale]
    I18n.locale = if locale && I18n.available_locales.include?(locale)
                    locale
                  else
                    I18n.default_locale
                  end
  end

  def store_request_id
    RequestStore.store[:request_id] = request.uuid
    append_to_log(request_id: RequestStore.store[:request_id])
    Raven.extra_context(request_id: RequestStore.store[:request_id])
  end

  def log_current_estates
    if current_estates
      append_to_log(estate_ids: current_estates.map(&:id))
    end
  end

  def log_current_user
    if current_user
      append_to_log(user_id: current_user.id)
    end
  end
end
