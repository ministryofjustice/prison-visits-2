module SmokeTest
  module Steps
    class PrisonBookingRequest < BaseStep
      include ImapProcessor

      def validate!
        fail 'Could not find prison booking request email' unless email
      end

      def complete_step
        visit booking_processing_url
      end

    private

      def expected_email_subject
        'Visit request for %s on %s' % [
          state.prisoner.full_name,
          state.first_slot_date_prison_format
        ]
      end

      def booking_processing_url
        Nokogiri::HTML(email.html_part.body.decoded).
          at('a:contains("Process the booking")')['href']
      end
    end
  end
end
