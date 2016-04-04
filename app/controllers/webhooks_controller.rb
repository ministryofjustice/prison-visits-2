class WebhooksController < ApplicationController
  before_action :authorized?

  def email
    if parsed_email.source == :prison
      PrisonMailer.autorespond(from_address).deliver_later
    else
      VisitorMailer.autorespond(from_address).deliver_later
    end
    render text: 'Accepted.'
  end

private

  def authorized?
    authorized = pad_execution_time(0.1) {
      params.key?(:auth) &&
      params[:auth] == Rails.configuration.webhook_auth_key
    }

    render text: 'Unauthorized.', status: 403 unless authorized
  end

  def parsed_email
    @parsed_email ||= ParsedEmail.parse(email_params)
  end

  def email_params
    params.slice(:from, :to, :subject, :text, :charsets)
  end

  # To prevent timing attacks, see commit #880e8cbf in pvb1 for more info
  def pad_execution_time(execution_time)
    start = Time.zone.now
    result = yield
    stop = Time.zone.now
    sleep execution_time - (stop - start)
    result
  end

  def from_address
    parsed_email.from.address
  end
end
