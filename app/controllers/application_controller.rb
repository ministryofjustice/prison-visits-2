class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :do_not_cache
  before_action :set_locale

  helper LinksHelper

private

  # :nocov:

  def append_to_log(params)
    @custom_log_items ||= {}
    @custom_log_items.merge!(params)
  end

  # Looks rather strange, but this is the suggested mechanism to add extra data
  # into the event passed to lograge's custom options. The method is part of
  # Rails' instrumentation code, and is run after each request.
  def append_info_to_payload(payload)
    super
    if @extra_log_items
      payload[:custom_log_items] = @custom_log_items
    end
  end

  # :nocov:

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
end
