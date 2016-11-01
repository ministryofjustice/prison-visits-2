class BookingResponder
  class Reject < BookingRequestProcessor
    def initialize(booking_response)
      super
      build_rejection
    end

    def process_request
      super do
        visit.reject!
        rejection.save!
      end
    end

  private

    def build_rejection
      rejection.reasons << booking_response.reason
      assign_allowance_renew_on
      assign_priviledged_allowance_expires_on
    end

    def rejection
      @rejection ||= Rejection.new(
        visit: visit,
        reason: booking_response.reason
      )
    end

    def assign_allowance_renew_on
      return unless booking_response.allowance_will_renew?

      rejection.allowance_renews_on =
        booking_response.allowance_renews_on
    end

    def assign_priviledged_allowance_expires_on
      return unless booking_response.privileged_allowance_available?

      rejection.privileged_allowance_expires_on =
        booking_response.privileged_allowance_expires_on
    end
  end
end
