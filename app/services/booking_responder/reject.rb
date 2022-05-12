class BookingResponder
  class Reject < BookingRequestProcessor
    def process_request(message = nil)
      super do
        visit.slot_granted = nil
        visit.closed       = nil
        visit.reference_no = nil
        clean_up_allowance_renews_on
        visit.reject!

        template_id = 'ee75661f-e1e8-4bfa-a599-4232d8f94216'

        rejection = visit.rejection.decorate
        @gov_notify_email = GovNotifyEmailer.new
        @gov_notify_email.send_email(visit, template_id, rejection, message)

        BookingResponse.successful
      end
    end

  private

    def clean_up_allowance_renews_on
      return if rejection.allowance_will_renew?

      visit.rejection.allowance_renews_on = nil
    end
  end
end
