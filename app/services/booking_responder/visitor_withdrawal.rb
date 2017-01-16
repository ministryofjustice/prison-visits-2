# frozen_string_literal: true
class BookingResponder
  class VisitorWithdrawal < BookingRequestProcessor
    def process_request
      super { visit.withdraw! }
    end
  end
end
