module Api
  ParameterError = Class.new(StandardError)

  class ApiController < ActionController::Base
    skip_before_action :verify_authenticity_token
    before_action :set_locale

    rescue_from ActionController::ParameterMissing do |e|
      render_error 422, "Missing parameter: #{e.param}"
    end

    rescue_from ParameterError do |e|
      render_error 422, "Invalid parameter: #{e.message}"
    end

  private

    def set_locale
      I18n.locale =
        http_accept_language.compatible_language_from(I18n.available_locales)
    end

    def render_error(status, message)
      render json: { message: message }, status: status
    end
  end
end
