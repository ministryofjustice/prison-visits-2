class BookingResponder
  class Cancel < BookingRequestProcessor
    def process_request(message = nil)
      super do
        visit.cancel!
        Cancellation.create!(visit: visit,
                             reason: staff_response.reason,
                             nomis_cancelled: true)
      end
    end
  end
end
