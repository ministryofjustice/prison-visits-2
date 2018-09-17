class BookingResponder
  class Reject < BookingRequestProcessor
    def process_request(message = nil)
      super do
        visit.slot_granted = nil
        visit.closed       = nil
        visit.reference_no = nil
        clean_up_allowance_renews_on
        visit.reject!

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
