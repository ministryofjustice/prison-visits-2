module SmokeTest
  module Steps
    class CheckYourRequestPage < BaseStep
      PAGE_PATH = '/request'

      def validate!
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
