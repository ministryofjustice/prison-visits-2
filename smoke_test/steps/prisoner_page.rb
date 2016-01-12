module SmokeTest
  module Steps
    class PrisonerPage < BaseStep
      include HttpStatusValidation

      PAGE_PATH = '/en/request'

      def validate!
        validate_response_status!

        if page.current_path != PAGE_PATH
          fail "expected #{PAGE_PATH}, got #{page.current_path}"
        end
      end

      # rubocop:disable Metrics/AbcSize
      def complete_step
        fill_in 'Prisoner first name', with: prisoner.first_name
        fill_in 'Prisoner last name', with: prisoner.last_name
        fill_in 'Day', with: prisoner.birth_day
        fill_in 'Month', with: prisoner.birth_month
        fill_in 'Year', with: prisoner.birth_year
        fill_in 'Prisoner number', with: prisoner.prison_number
        select_prison(prisoner.prison_name)
        click_button 'Continue'
      end

    # rubocop:enable Metrics/AbcSize

    private

      def select_prison(name)
        find('input[data-input-name="prisoner_step[prison_id]"]').
          set(name)
      end

      def_delegator :state, :prisoner
    end
  end
end
