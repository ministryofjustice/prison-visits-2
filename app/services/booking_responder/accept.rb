class BookingResponder
  class Accept < BookingRequestProcessor
    def process_request(message = nil)
      super do
        visit.rejection = nil
        visit.accept!

        if options[:persist_to_nomis]
          book_to_nomis
        else
          BookingResponse.successful
        end
      end
    end

  private

    def book_to_nomis
      booking_response = nomis_visit_creator.execute

      if booking_response.success?
        visit.update!(
          nomis_id:    nomis_visit_creator.nomis_visit_id,
          visit_order: nomis_visit_creator.visit_order
        )
      end

      booking_response
    end

    def nomis_visit_creator
      @nomis_visit_creator ||= CreateNomisVisit.new(visit)
    end
  end
end
