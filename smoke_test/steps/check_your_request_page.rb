module SmokeTest
  module Steps
    class CheckYourRequestPage < BaseStep
      include HttpStatusValidation

      PAGE_PATH = '/request'

      def validate!
        validate_response_status!

        if page.current_path != PAGE_PATH
          fail "expected #{PAGE_PATH}, got #{page.current_path}"
        end
      end

      def complete_step
        click_button 'Send request'
      end
    end
  end
end
