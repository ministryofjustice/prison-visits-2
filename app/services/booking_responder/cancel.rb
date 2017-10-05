class BookingResponder
  class Cancel < BookingRequestProcessor
    def process_request(message = nil)
      super do
        visit.cancel!
        Cancellation.create!(visit: visit,
                             reasons: staff_response.reasons,
                             nomis_cancelled: true)

        BookingResponse.successful
      end
    end
  end
end
