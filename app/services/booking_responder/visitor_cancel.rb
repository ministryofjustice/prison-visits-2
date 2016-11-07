class BookingResponder
  class VisitorCancel < BookingRequestProcessor
    def process_request
      super(nil) do
        visit.cancel!
        Cancellation.create!(visit: visit,
                             reason: Cancellation::VISITOR_CANCELLED,
                             nomis_cancelled: false)
      end
    end
  end
end
