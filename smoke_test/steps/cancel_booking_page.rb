module SmokeTest
  module Steps
    class CancelBookingPage < BaseStep
      PAGE_PATH = %r{\A/visits/([0-9a-f-]){36}}

      def validate!
        unless PAGE_PATH.match page.current_path
          fail "expected #{PAGE_PATH}, got #{page.current_path}"
        end
      end

      def complete_step
        check 'Yes, I want to cancel this visit'
        click_button 'Cancel visit'
      end
    end
  end
end
