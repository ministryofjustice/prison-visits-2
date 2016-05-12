module Api
  ParameterError = Class.new(StandardError)

  class ApiController < ActionController::Base
    skip_before_action :verify_authenticity_token
    before_action :set_locale
    before_action :store_request_id
    before_action :enforce_json

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

    # WARNING: This a Rails private method, could easily break in the future.
    #
    # Looks rather strange, but this is the suggested mechanism to add extra
    # data into the event passed to lograge's custom options. The method is
    # part of Rails' instrumentation code, and is run after each request.
    def append_info_to_payload(payload)
      super

      payload[:custom_log_items] = {
        request_id: RequestStore.store[:request_id]
      }
    end

    def store_request_id
      RequestStore.store[:request_id] = request.uuid
      Raven.extra_context(request_id: RequestStore.store[:request_id])
    end

    def enforce_json
      unless request.format.to_sym == :json
        render_error 406, 'Only JSON supported'
      end
    end
  end
end
