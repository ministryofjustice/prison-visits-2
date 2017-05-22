class BookingResponder
  class Accept < BookingRequestProcessor
    def process_request(message = nil)
      super do
        visit.rejection = nil
        visit.accept!

        BookingResponse.new(success: true)
      end
    end
  end
end
