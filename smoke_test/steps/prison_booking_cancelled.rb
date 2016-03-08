module SmokeTest
  module Steps
    class PrisonBookingCancelled < BaseStep
      include ImapProcessor

      def validate!
        fail 'Could not find prison booking cancelled email' unless email
      end

      def complete_step
        # nothing for us to do with this email
      end

    private

      def expected_email_subject
        'CANCELLED: Visit for %s on %s' % [
          state.prisoner.full_name,
          state.first_slot_date_prison_format
        ]
      end
    end
  end
end
