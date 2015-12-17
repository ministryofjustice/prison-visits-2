module SmokeTest
  module Steps
    class PrisonBookingCancelled < BaseStep
      include WithRetries

      def validate!
        fail 'Could not find prison booking cancelled email' unless email
      end

      def complete_step
        # nothing for us to do with this page
      end

    private

      def email
        @email ||= with_retries {
          MailBox.find_email state.unique_email_address, expected_email_subject
        }
      end

      def expected_email_subject
        'CANCELLED: %s on %s' % [
          state.prisoner.full_name,
          state.first_slot_date_prison_format
        ]
      end
    end
  end
end
