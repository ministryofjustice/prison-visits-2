# rubocop:disable Rails/ApplicationController

module Api
  ParameterError = Class.new(StandardError)

  class ApiController < ActionController::Base
    API_SLA = 2.seconds

    skip_before_action :verify_authenticity_token, raise: false
    before_action :set_locale
    before_action :store_request_id
    before_action :enforce_json

    around_action :set_and_check_deadline

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

    def set_and_check_deadline
      RequestStore.store[:deadline] = Time.zone.now + API_SLA
      yield
      elapsed = RequestStore.store[:deadline] - Time.zone.now
      PVB::Instrumentation.append_to_log(deadline_exceeded: elapsed < 0)
    end

    def set_locale
      I18n.locale = request.headers['Accept-Language']
    end

    def render_error(status, message)
      render json: { message: message }, status: status
    end

    def store_request_id
      RequestStore.store[:request_id] = request.uuid
      PVB::Instrumentation.append_to_log(request_id: RequestStore.store[:request_id])
      Sentry.set_extras(request_id: RequestStore.store[:request_id])
    end

    def enforce_json
      unless request.format.to_sym == :json
        render_error 406, 'Only JSON supported'
      end
    end

    def verify_token
      access_token = parse_access_token(request.headers['AUTHORIZATION'])

      token = Nomis::Oauth::Token.new(access_token: access_token)
      unless token.valid_token_with_scope?('read', role: API_ROLE)
        render_error('Valid authorisation token required')
      end
    end

    def parse_access_token(auth_header)
      return nil if auth_header.nil?
      return nil unless auth_header.starts_with?('Bearer')

      auth_header.split.last
    end
  end
end
# rubocop:enable Rails/ApplicationController
