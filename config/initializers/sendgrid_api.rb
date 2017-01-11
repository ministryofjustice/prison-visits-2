# frozen_string_literal: true
if Rails.configuration.disable_sendgrid_validations
  Rails.logger.warn('App starting with Sendgrid disabled')
  SendgridApi.instance.disable
end
