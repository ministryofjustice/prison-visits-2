require 'action_mailer/inline_preview_interceptor'

class Prison::EmailPreviewsController < ApplicationController
  include StaffResponseContext

  def update
    if staff_response.valid?
      render html: email_preview
    else
      render(
        text: staff_response.
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

  def staff_response
    @staff_response ||= begin
      memoised_visit.assign_attributes(visit_params)
      StaffResponse.new(
        visit: memoised_visit,
        validate_visitors_nomis_ready: params[:validate_visitors_nomis_ready])
    end
  end

  def visitor_mailer
    responder = BookingResponder.new(
      staff_response.visit,
      message: message,
      options: booking_responder_opts)
    responder.visitor_mailer
  end
end
