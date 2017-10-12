class BookingResponder
  class Cancel < BookingRequestProcessor
    def process_request(message = nil)
      super do
        visit.cancel!
        visit.cancellation.save!
        if options[:persist_to_nomis]
          cancel_to_nomis(message)
        else
          BookingResponse.successful
        end
      end
    end

  private

    def cancel_to_nomis(message)
      return nomis_visit_cancellation.execute(comment: message) if cancel_nomis_visit?
      BookingResponse.successful
    end

    def cancel_nomis_visit?
      Nomis::Feature.book_to_nomis_enabled?(visit.prison_name) && visit.nomis_id?
    end

    def nomis_visit_cancellation
      @nomis_visit_cancellation ||= CancelNomisVisit.new(visit)
    end
  end
end
