require 'action_mailer/inline_preview_interceptor'

class Prison::EmailPreviewsController < ApplicationController
  include BookingResponseContext

  def show
    if booking_response.valid?
      render html: email_preview
    else
      render text: booking_response.errors.full_messages
    end
  end

private

  def email_preview
    @email_preview ||= ActionMailer::InlinePreviewInterceptor.
                       previewing_email(visitor_mailer).
                       html_part.body.decoded.html_safe
  end

  def booking_response
    @booking_response ||=
      BookingResponse.new(visit: Visit.new(visit_params))
  end

  def visitor_mailer
    @visitor_mailer ||=
      BookingResponder.new(booking_response, message).visitor_mailer
  end
end
