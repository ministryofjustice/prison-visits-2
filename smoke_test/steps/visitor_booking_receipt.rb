module SmokeTest
  module Steps
    class VisitorBookingReceipt < BaseStep
      include ImapProcessor

      def validate!
        fail 'Could not find visitor booking receipt email' unless email
      end

      def complete_step
        # nothing for us to do with this email
      end

    private

      def expected_email_subject
        "Not booked yet: we've received your visit request for %s" % [
          state.first_slot_date_visitor_format
        ]
      end
    end
  end
end
