require 'action_mailer/inline_preview_interceptor'

class Prison::EmailPreviewsController < ApplicationController
  include StaffResponseContext

  def update
    memoised_visit.assign_attributes(visit_params)
    if staff_response.valid?
      render html: email_preview
    else
      render(
        body: staff_response
          .errors.full_messages.to_sentence,
        status: :not_acceptable
      )
    end
  end

private

  def email_preview
    @email_preview ||= ActionMailer::InlinePreviewInterceptor
                       .previewing_email(visitor_mailer)
                       .html_part.body.decoded.html_safe
  end

  def visitor_mailer
    booking_responder.visitor_mailer
  end
end
