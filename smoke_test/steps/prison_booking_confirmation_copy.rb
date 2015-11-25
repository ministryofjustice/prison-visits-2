module SmokeTest
  module Steps
    class PrisonBookingConfirmationCopy < BaseStep
      def validate!
        unless email
          fail 'Could not find prison booking confirmation copy email'
        end
      end

      def complete_step
        # nothing for us to do with this email
      end

    private

      def email
        @email ||= with_retries {
          MailBox.find_email state.unique_email_address, expected_email_subject
        }
      end

      def expected_email_subject
        'COPY of booking confirmation for %s' % [state.prisoner.full_name]
      end
    end
  end
end
