class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :do_not_cache
  before_action :set_locale
  before_action :store_request_id

  helper LinksHelper
  helper_method :current_user

  def current_user
    @_current_user ||= User.find_by(id: session[:current_user_id])
  end

private

  def set_inbox_navigation_count
    @inbox_count = EstateVisitQuery.new(current_user.estate).inbox_count
  end

  # :nocov:

  def authorize_prison_request
    unless Rails.configuration.prison_ip_matcher.include?(request.remote_ip)
      Rails.logger.info "Unauthorized request from #{request.remote_ip}"
      fail ActionController::RoutingError, 'Not Found'
    end
  end

  def authenticate_user
    unless current_user
      session[:redirect_path] = request.original_fullpath
      redirect_to '/auth/mojsso'
    end
  end

  def append_to_log(params)
    @custom_log_items ||= {}
    @custom_log_items.merge!(params)
  end

  # WARNING: This a Rails private method, could easily break in the future.
  #
  # Looks rather strange, but this is the suggested mechanism to add extra data
  # into the event passed to lograge's custom options. The method is part of
  # Rails' instrumentation code, and is run after each request.
  def append_info_to_payload(payload)
    super
    payload[:custom_log_items] = @custom_log_items
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
    I18n.locale = params.fetch(:locale, I18n.default_locale)
  end

  def store_request_id
    append_to_log(request_id: RequestStore.store[:request_id])
    RequestStore.store[:request_id] = request.uuid
    Raven.extra_context(request_id: RequestStore.store[:request_id])
  end
end
