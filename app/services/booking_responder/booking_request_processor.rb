class BookingResponder
  class BookingRequestProcessor
    def initialize(booking_response)
      @booking_response = booking_response
    end

    def process_request(message)
      ActiveRecord::Base.transaction do
        yield if block_given?
        create_message(message, visit.last_visit_state) if message
        record_user(visit.last_visit_state)
      end
    end

  private

    attr_reader :booking_response

    delegate :visit, to: :booking_response
    delegate :rejection, to: :visit
    private :visit

    def create_message(message, visit_state_change)
      message.user_id ||= booking_response.user&.id
      return unless message.valid?

      message.update!(
        visit:              visit,
        visit_state_change: visit_state_change
      )
    end

    def record_user(visit_state_change)
      visit_state_change.update!(processed_by: booking_response.user)
    end
  end
end
