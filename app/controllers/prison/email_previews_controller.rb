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
      visit = load_visit
      visit.assign_attributes(visit_params)
      StaffResponse.new(visit: visit)
    end
  end

  def visitor_mailer
    @visitor_mailer ||=
      BookingResponder.new(staff_response.visit, message: message).visitor_mailer
  end
end
