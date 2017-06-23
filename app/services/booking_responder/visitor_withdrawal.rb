class BookingResponder
  class VisitorWithdrawal < BookingRequestProcessor
    def process_request
      super do
        visit.withdraw!

        BookingResponse.successful
      end
    end
  end
end
