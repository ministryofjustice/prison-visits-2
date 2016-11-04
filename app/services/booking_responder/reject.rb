class BookingResponder
  class Reject < BookingRequestProcessor
    def process_request(message = nil)
      super do
        visit.slot_granted = nil
        visit.closed       = nil
        visit.reference_no = nil
        clean_up_allowance_renews_on
        clean_up_privileged_allowance_expires_on
        visit.reject!
      end
    end

  private

    def clean_up_allowance_renews_on
      return if rejection.allowance_will_renew?
      visit.rejection.allowance_renews_on = nil
    end

    def clean_up_privileged_allowance_expires_on
      return if rejection.privileged_allowance_available?
      visit.rejection.privileged_allowance_expires_on = nil
    end
  end
end
