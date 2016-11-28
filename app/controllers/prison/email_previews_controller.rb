require 'action_mailer/inline_preview_interceptor'

class Prison::EmailPreviewsController < ApplicationController
  include BookingResponseContext

  def update
    if booking_response.valid?
      render html: email_preview
    else
      render(
        text: booking_response.
          errors.full_messages.to_sentence,
        status: :not_acceptable
      )
    end
  end

private

  def email_preview
    @email_preview ||= ActionMailer::InlinePreviewInterceptor.
                       previewing_email(visitor_mailer).
                       html_part.body.decoded.html_safe
  end

  def booking_response
    @booking_response ||= begin
      visit = load_visit
      visit.assign_attributes(visit_params)
      BookingResponse.new(visit: visit)
    end
  end

  def visitor_mailer
    @visitor_mailer ||=
      BookingResponder.new(booking_response, message).visitor_mailer
  end
end
