module SmokeTest
  module Steps
    class ProcessVisitRequestPage < BaseStep
      PAGE_PATH = %r{/prison/visits/([0-9a-f-]){36}}

      def validate!
        unless page.current_path.match(PAGE_PATH)
          fail "expected #{PAGE_PATH} to match #{page.current_path}"
        end
      end

      def complete_step
        choose 'Choice 1'
        fill_in 'Reference number', with: process_data.vo_digits
        click_button 'Send email'
      end

    private

      def process_data
        state.process_data
      end
    end
  end
end
