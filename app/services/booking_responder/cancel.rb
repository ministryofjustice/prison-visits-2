class BookingResponder
  class Cancel < BookingRequestProcessor
    def process_request(message = nil)
      super do
        visit.cancel!
        visit.cancellation.save!
        BookingResponse.successful
      end
    end
  end
end
