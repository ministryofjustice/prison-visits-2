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

    rescue_from ActiveRecord::RecordNotFound do
      render_error 404, 'Not found'
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render_error 422, e.record.errors.full_messages.join(', ')
    end

  private

    def set_locale
      I18n.locale = request.headers['Accept-Language']
    end

    def render_error(status, message)
      render json: { message: message }, status: status
    end
  end
end
