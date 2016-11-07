class BookingResponder
  class VisitorWithdrawal < BookingRequestProcessor
    def process_request
      super { visit.withdraw! }
    end
  end
end
