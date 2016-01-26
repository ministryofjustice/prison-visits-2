class ApiController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :set_locale

private

  def set_locale
    I18n.locale =
      http_accept_language.compatible_language_from(I18n.available_locales)
  end
end
