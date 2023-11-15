class BookingResponder
  class VisitorCancel < BookingRequestProcessor
    def process_request
      super do
        visit.cancel!
        Cancellation.create!(visit:,
                             reasons: [Cancellation::VISITOR_CANCELLED],
                             nomis_cancelled: false)

        BookingResponse.successful
      end
    end
  end
end
