module SmokeTest
  module Steps
    class SlotsPage < BaseStep
      include HttpStatusValidation

      PAGE_PATH = '/en/request'

      def validate!
        validate_response_status!

        if page.current_path != PAGE_PATH
          fail "expected #{PAGE_PATH}, got #{page.current_path}"
        end
      end

      def complete_step
        select_three_visiting_slots
        state.slot_data = selected_dates_and_times
        click_button 'Continue'
      end

    private

      def select_three_visiting_slots
        available_dates_on_calendar.
          take(3).
          each do |calendar_date|
            calendar_date.click
            click_first_available_time
          end
      end

      def available_dates_on_calendar
        all('.BookingCalendar-date--bookable')
      end

      def click_first_available_time
        all('.SlotPicker-label').first.click
      end

      def selected_dates_and_times
        page.all('.SlotPicker-choice').reduce([]) do |slots, el|
          slot_data = {
            date: el.find('.SlotPicker-date').text,
            time: el.find('.SlotPicker-time').text
          }
          slots << slot_data
        end
      end
    end
  end
end
