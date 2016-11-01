class BookingResponder
  class Accept < BookingRequestProcessor
    def process_request
      super do
        visit.accept!
        visit.update!(
          slot_granted: booking_response.slot_granted,
          reference_no: booking_response.reference_no,
          closed:       booking_response.closed_visit
        )
      end
    end
  end
end
