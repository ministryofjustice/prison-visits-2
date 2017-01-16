# frozen_string_literal: true
class BookingResponder
  class Accept < BookingRequestProcessor
    def process_request(message = nil)
      super do
        visit.rejection = nil
        visit.accept!
      end
    end
  end
end
