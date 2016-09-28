require 'action_mailer/inline_preview_interceptor'

class Prison::EmailPreviewsController < ApplicationController
  include BookingResponseContext

  def show
    render html: email_preview
  end

private

  def email_preview
    @email_preview ||= ActionMailer::InlinePreviewInterceptor.
                       previewing_email(visitor_mailer).
                       html_part.body.decoded.html_safe
  end

  def booking_response
    @booking_response ||=
      BookingResponse.new(booking_response_params)
  end

  def visitor_mailer
    @visitor_mailer ||=
      BookingResponder.new(booking_response).visitor_mailer
  end
end
