class BookingResponder
  class VisitorWithdrawal < BookingRequestProcessor
    def process_request
      super do
        visit.withdraw!

        BookingResponse.new(success: true)
      end
    end
  end
end
