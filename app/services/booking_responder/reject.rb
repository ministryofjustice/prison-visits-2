class BookingResponder
  class Reject < BookingRequestProcessor
    def initialize(booking_response)
      super
      @rejection = build_rejection(visit, booking_response)
    end

    def process_request
      super do
        visit.reject!
        @rejection.save!
      end
    end

  private

    def build_rejection(visit, booking_response)
      rejection = Rejection.new(visit: visit, reason: booking_response.reason)

      return rejection unless booking_response.no_allowance?

      if booking_response.allowance_will_renew?
        rejection.allowance_renews_on = booking_response.allowance_renews_on
      end

      if booking_response.privileged_allowance_available?
        rejection.privileged_allowance_expires_on =
          booking_response.privileged_allowance_expires_on
      end

      rejection
    end
  end
end
