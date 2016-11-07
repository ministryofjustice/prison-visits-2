class BookingResponder
  class VisitorWithdrawal < BookingRequestProcessor
    def process_request
      super(nil) { visit.withdraw! }
    end
  end
end
